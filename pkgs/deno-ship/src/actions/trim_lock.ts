import { resolve, toFileUrl } from "@std/path";
import { DenoDir, FetchCacher, FileFetcher } from "@deno/cache-dir";
import { parseImportMapFromJson } from "../../_shared/import_map.ts";
import { createCliAction, ExitCode } from "@wok/utils/cli";
import { Arr, NonEmpStr, Opt } from "@wok/schema/schema";
import { createGraph } from "$shared/graph.ts";

interface DenoLockPackage {
  dependencies?: string[];
}

interface DenoLock {
  specifiers: Record<string, string>;
  jsr: Record<string, DenoLockPackage>;
  npm: Record<string, DenoLockPackage>;
}

interface ResolvedPackage {
  name: string;
  dependencies?: string[];
}

class Dependency {
  private _specifier?: string;
  constructor(
    public type: "npm" | "jsr",
    public name: string,
    public mappedFromSpecifier?: string,
  ) {}
  get specifier() {
    if (this._specifier === undefined) {
      this._specifier = this.type + ":" + this.name;
    }
    return this._specifier;
  }
}

export const trimLockAction = createCliAction(
  {
    denoDir: Opt(
      NonEmpStr({ description: "Path to the deno cache directory" }),
    ),
    config: NonEmpStr({ description: "Path to the import map (deno.json)" }),
    lock: NonEmpStr({ description: "Path to the lock file (deno.lock)" }),
    _: Arr(NonEmpStr(), {
      minItems: 1,
      description: "One or more paths to source files",
    }),
  },
  async (
    {
      denoDir: denoDirPath,
      config: configPath,
      lock: lockPath,
      _: srcPaths,
    },
  ) => {
    const resolvedDependencies = new Map<string, string>();
    const resolvedConfigPath = resolve(configPath);
    const resolvedLockPath = resolve(lockPath);

    const denoDir = new DenoDir(denoDirPath);
    const fileFetcher = new FileFetcher(
      () =>
        denoDir.createHttpCache({
          readOnly: true,
        }),
      "only",
    );
    const cacher = new FetchCacher(fileFetcher);
    const lock: DenoLock = JSON.parse(
      await Deno.readTextFile(resolvedLockPath),
    );
    const resolvedImportMap = await parseImportMapFromJson(
      toFileUrl(resolvedConfigPath),
      await Deno.readTextFile(resolvedConfigPath),
    );

    const lockSpecifierEntries = Object.entries(lock.specifiers);

    function mapSpecifier(specifier: string) {
      if (!specifier.startsWith("npm:") && !specifier.startsWith("jsr:")) {
        return specifier;
      }

      const normalized = specifier.startsWith("jsr:/")
        ? ("jsr:" + specifier.slice(5))
        : specifier;

      for (const [from, to] of lockSpecifierEntries) {
        if (normalized === from) {
          const li = specifier.lastIndexOf("@");
          const prefix = specifier.slice(0, li);
          const mapped = prefix + "@" + to;
          resolvedDependencies.set(specifier, mapped);
          return mapped;
        } else if (
          normalized.startsWith(from) && normalized[from.length] === "/"
        ) {
          const li = specifier.lastIndexOf("@");
          const prefix = specifier.slice(0, li);
          const remaining = specifier.slice(li + 1);
          const slashIndex = remaining.indexOf("/");
          const suffix = slashIndex !== -1 ? remaining.slice(slashIndex) : "";
          return prefix + "@" + to + suffix;
        }
      }

      return specifier;
    }

    function resolvePackage(
      packageMap: Record<string, DenoLockPackage>,
      { type, name }: Dependency,
    ): ResolvedPackage {
      const pkg = packageMap[name];

      if (pkg === undefined) {
        const prefix = name + "@";
        for (const [key, value] of Object.entries(packageMap)) {
          if (key.startsWith(prefix)) {
            return {
              name: key,
              dependencies: value.dependencies,
            };
          }
        }

        throw new Error(
          `Could not find ${type} package in the lock file: ${name}`,
        );
      }

      return {
        name,
        dependencies: pkg.dependencies,
      };
    }

    function mapDependency(dep: Dependency) {
      let version = lock.specifiers[dep.specifier];
      let mappedFromSpecifier: undefined | string;

      if (version === undefined && dep.specifier.includes("@^0.")) {
        mappedFromSpecifier = dep.specifier.replace("@^0.", "@~0.");
        version = lock.specifiers[mappedFromSpecifier];
      }

      if (version !== undefined) {
        const prefix = dep.name.slice(0, dep.name.lastIndexOf("@"));
        return new Dependency(
          dep.type,
          prefix + "@" + version,
          mappedFromSpecifier,
        );
      }

      return dep;
    }

    function resolveDependencies(item: Dependency) {
      if (resolvedDependencies.has(item.specifier)) {
        return;
      }

      const mapped = mapDependency(item);
      if (resolvedDependencies.has(mapped.specifier)) {
        if (item.mappedFromSpecifier) {
          resolvedDependencies.set(
            item.mappedFromSpecifier,
            resolvedDependencies.get(mapped.specifier)!,
          );
        }
        resolvedDependencies.set(
          item.specifier,
          resolvedDependencies.get(mapped.specifier)!,
        );
        return;
      }

      if (mapped.type === "npm") {
        const pkg = resolvePackage(lock.npm, mapped);
        const resolved = `npm:${pkg.name}`;
        if (mapped.mappedFromSpecifier) {
          resolvedDependencies.set(mapped.mappedFromSpecifier, resolved);
        }
        resolvedDependencies.set(item.specifier, resolved);
        resolvedDependencies.set(mapped.specifier, resolved);

        if (pkg.dependencies) {
          for (const dep of pkg.dependencies) {
            resolveDependencies(new Dependency("npm", dep));
          }
        }
      } else {
        const pkg = resolvePackage(lock.jsr, mapped);
        const resolved = `jsr:${pkg.name}`;
        if (mapped.mappedFromSpecifier) {
          resolvedDependencies.set(mapped.mappedFromSpecifier, resolved);
        }
        resolvedDependencies.set(item.specifier, resolved);
        resolvedDependencies.set(mapped.specifier, resolved);

        if (pkg.dependencies) {
          for (const dep of pkg.dependencies) {
            if (dep.startsWith("npm:")) {
              resolveDependencies(new Dependency("npm", dep.slice(4)));
            } else if (dep.startsWith("jsr:")) {
              resolveDependencies(new Dependency("jsr", dep.slice(4)));
            } else {
              throw new Error(
                `Unexpected dependency of ${mapped.specifier} - neither jsr nor npm: ${dep}`,
              );
            }
          }
        }
      }
    }

    for (const srcPath of srcPaths) {
      const graph = await createGraph(toFileUrl(resolve(srcPath)).href, {
        async load(specifier, isDynamic, _cacheSetting, checksum) {
          if (specifier.startsWith("node:") || specifier.startsWith("data:")) {
            return {
              kind: "external",
              specifier,
            };
          }
          return await cacher.load(specifier, isDynamic, "only", checksum);
        },
        resolve(specifier, referrer) {
          const resolved = resolvedImportMap.resolve(specifier, referrer);
          const mapped = mapSpecifier(resolved);
          // console.error(specifier, ">", resolved, ">", mapped);
          return mapped;
        },
      });

      for (const mod of graph.modules) {
        if (mod.error) {
          throw new Error(
            `Failed resolving from cache ${mod.specifier}: ${mod.error}`,
          );
        }

        if (
          mod.kind === "external" && mod.specifier.startsWith("npm:") &&
          !mod.specifier.startsWith("npm:/")
        ) {
          resolveDependencies(new Dependency("npm", mod.specifier.slice(4)));
        }
      }

      const graphPackages: Record<string, string> | undefined =
        // deno-lint-ignore no-explicit-any
        (graph as unknown as any).packages;

      if (graphPackages) {
        for (
          const p of Object.values(graphPackages)
        ) {
          resolveDependencies(new Dependency("jsr", p));
        }
      }
    }

    const resolvedDependencySet = new Set(resolvedDependencies.values());

    console.error(
      JSON.stringify(
        Object.fromEntries(
          Array
            .from(resolvedDependencies.entries())
            .sort(([a], [b]) => a.localeCompare(b)),
        ),
        null,
        2,
      ),
    );
    console.log(JSON.stringify(
      {
        ...lock,
        specifiers: Object.fromEntries(
          lockSpecifierEntries.filter(([key]) =>
            !key.startsWith("npm:") || resolvedDependencies.has(key)
          ),
        ),
        jsr: Object.fromEntries(
          Object.entries(lock.jsr).filter(([key]) =>
            resolvedDependencySet.has(`jsr:${key}`)
          ),
        ),
        npm: Object.fromEntries(
          Object.entries(lock.npm).filter(([key]) =>
            resolvedDependencySet.has(`npm:${key}`)
          ),
        ),
      },
      null,
      2,
    ));

    return ExitCode.Zero;
  },
);
