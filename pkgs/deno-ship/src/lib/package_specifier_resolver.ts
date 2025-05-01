import { resolve, toFileUrl } from "@std/path";
import { DenoDir, FetchCacher, FileFetcher } from "@deno/cache-dir";
import { createGraph } from "./graph.ts";
import {
  PackageName,
  PackageSpecifier,
  PackageType,
  parsePackageSpecifier,
  stringifyPackageSpecifier,
} from "./package_specifier.ts";
import { assertExists } from "@std/assert/exists";
import { Tagged } from "type-fest";
import { parseRange } from "@std/semver/parse-range";
import { formatRange } from "@std/semver/format-range";
import { Range } from "@std/semver/types";
import { ImportMap } from "@deno/import-map";

type PackageVersionReq = Tagged<string, "PackageVersionReq">;
type PackageVersion = Tagged<string, "PackageVersion">;
type PackageRange = Tagged<string, "PackageRange">;

interface ResolvedPackageSpecifier extends PackageSpecifier {
  version: PackageVersion;
}

interface DenoLockPackage {
  dependencies?: string[];
  optionalDependencies?: string[];
}

export interface DenoLock {
  specifiers: Record<string, PackageVersion>;
  jsr: Record<string, DenoLockPackage>;
  npm: Record<string, DenoLockPackage>;
}

interface PackageVersionLock {
  range?: PackageRange;
  req: PackageVersionReq;
  version: PackageVersion;
}

type PackageNameVersionRegistry = Record<
  PackageName,
  PackageVersionLock[]
>;
type PackageTypeVersionRegistry = Record<
  PackageType,
  PackageNameVersionRegistry
>;

export interface PackageSpecifierResolver {
  resolve(specifier: string): ResolvedPackageSpecifier;
  cache: Map<string, PackageSpecifier>;
  registry: PackageTypeVersionRegistry;
}

function isResolvedSpecifier(
  specifier: PackageSpecifier,
): specifier is ResolvedPackageSpecifier {
  return specifier.version !== undefined && isVersionExact(specifier.version);
}

function isVersionExact(version: string): version is PackageVersion {
  let range: Range | undefined;

  try {
    range = parseRange(version);
  } catch {
    // Ignore
  }

  if (
    range !== undefined && range.length === 1 && range[0].length === 1 &&
    range[0][0].operator === undefined
  ) {
    return true;
  }

  return range === undefined;
}

function parsePackageSpecifierOrThrow(specifier: string): PackageSpecifier {
  const parsed = parsePackageSpecifier(specifier);
  if (parsed === undefined) {
    throw new Error(`Invalid package specifier: ${specifier}`);
  }
  return parsed;
}

function parseMaybeRange(version: string): PackageRange | undefined {
  try {
    return formatRange(parseRange(version)) as PackageRange;
  } catch {
    return undefined;
  }
}

function createFallbackPackageNameVersionRegistry(
  type: PackageType,
  lock: Record<string, DenoLockPackage>,
): PackageNameVersionRegistry {
  return Object.keys(lock).map((s) => {
    const info = parsePackageSpecifierOrThrow(type + ":" + s);
    assertExists(info.version, `Version requirement is not defined in: ${s}`);
    return {
      name: info.name,
      version: info.version,
    };
  }).reduce((acc, entry) => {
    if (!acc[entry.name]) {
      acc[entry.name] = [];
    }

    acc[entry.name].push({
      version: entry.version as PackageVersion,
      req: entry.version as PackageVersionReq,
    });

    return acc;
  }, {} as PackageNameVersionRegistry);
}

function createPackageSpecifierResolver(
  lock: DenoLock,
): PackageSpecifierResolver {
  const specifierEntries = Object.entries(lock.specifiers).map(
    ([specifier, version]) => {
      const info = parsePackageSpecifierOrThrow(specifier);
      assertExists(
        info.version,
        `Version requirement is not defined in: ${specifier}`,
      );

      return {
        type: info.type,
        name: info.name,
        versionReq: info.version as PackageVersionReq,
        version,
      };
    },
  );

  const registry = specifierEntries.reduce((acc, entry) => {
    if (!acc[entry.type]) {
      acc[entry.type] = {};
    }
    if (!acc[entry.type][entry.name]) {
      acc[entry.type][entry.name] = [];
    }

    acc[entry.type][entry.name].push({
      range: parseMaybeRange(entry.versionReq),
      version: entry.version,
      req: entry.versionReq,
    });

    return acc;
  }, {} as PackageTypeVersionRegistry);

  const fallbackRegistry = {
    npm: createFallbackPackageNameVersionRegistry(
      "npm",
      lock.npm,
    ),
    jsr: createFallbackPackageNameVersionRegistry(
      "jsr",
      lock.npm,
    ),
  } as const;

  const cache = new Map<string, ResolvedPackageSpecifier>();

  const resolve = (request: string): ResolvedPackageSpecifier => {
    const { path, ...specifier } = parsePackageSpecifierOrThrow(request);
    const specifierString = stringifyPackageSpecifier(specifier);

    const cached = cache.get(specifierString);
    if (cached !== undefined) {
      return {
        ...cached,
        path,
      };
    }

    if (isResolvedSpecifier(specifier)) {
      cache.set(specifierString, specifier);
      return {
        ...specifier,
        path,
      };
    }

    const versionReq = specifier.version as PackageVersionReq;
    let lockedVersions = registry[specifier.type][specifier.name] ?? [];

    if (versionReq === undefined) {
      if (lockedVersions.length === 0) {
        lockedVersions = fallbackRegistry[specifier.type][specifier.name] ?? [];
      }

      if (lockedVersions.length === 0) {
        throw new Error(
          `There is no locked or known version for package name: ${
            JSON.stringify(specifier.name)
          }. The requested specifier is: ${JSON.stringify(request)}`,
        );
      }

      if (lockedVersions.length > 1) {
        const versionSet = new Set(lockedVersions.map((v) => v.version));

        if (versionSet.size > 1) {
          throw new Error(
            `A specifier leads to ambiguous version resolution: ${
              JSON.stringify(request)
            }. There are multiple locked versions for package name: ${
              JSON.stringify(specifier.name)
            }. All known locked versions are: ${[...versionSet].join(", ")}`,
          );
        }
      }

      const lockedVersion = lockedVersions[0];

      const result = {
        ...specifier,
        version: lockedVersion.version,
      } satisfies PackageSpecifier;

      cache.set(
        stringifyPackageSpecifier({
          ...specifier,
          version: lockedVersion.req,
        }),
        result,
      );
      cache.set(stringifyPackageSpecifier(result), result);

      return {
        ...result,
        path,
      };
    }

    const requestedRange = parseMaybeRange(versionReq);

    if (requestedRange === undefined) {
      throw new Error(
        `Invalid version range: ${JSON.stringify(versionReq)} in specifier: ${
          JSON.stringify(request)
        }`,
      );
    }

    for (const lockedVersion of lockedVersions) {
      if (lockedVersion.range === requestedRange) {
        const result = {
          ...specifier,
          version: lockedVersion.version,
        } satisfies PackageSpecifier;

        cache.set(
          stringifyPackageSpecifier({
            ...specifier,
            version: lockedVersion.req,
          }),
          result,
        );

        return {
          ...result,
          path,
        };
      }
    }

    throw new Error(
      `Could not find a matching locked version for specifier: ${
        JSON.stringify(request)
      }. Known mapping: ${
        JSON.stringify(
          Object.fromEntries(lockedVersions.map((v) => [v.req, v.version])),
        )
      }`,
    );
  };

  return {
    registry,
    cache,
    resolve,
  };
}

export async function buildPackageSpecifierResolver(
  { denoDir, importMap, lock, srcPaths }: {
    denoDir: DenoDir;
    importMap: ImportMap;
    lock: DenoLock;
    srcPaths: string[];
  },
) {
  const fileFetcher = new FileFetcher(
    () =>
      denoDir.createHttpCache({
        readOnly: true,
      }),
    "only",
  );
  const cacher = new FetchCacher(fileFetcher);

  const packageSpecifierResolver = createPackageSpecifierResolver(lock);

  function resolvePackage(
    map: Record<string, DenoLockPackage>,
    spec: ResolvedPackageSpecifier,
  ) {
    const versionedName = spec.name + "@" + spec.version;
    const pkg = map[versionedName];

    if (!pkg) {
      throw new Error(
        `Package of type ${spec.type} not found in lock: ${versionedName}`,
      );
    }

    return pkg;
  }

  function resolveDependencies(specifier: string) {
    const spec = packageSpecifierResolver.resolve(specifier);
    const pkg = resolvePackage(
      spec.type === "npm" ? lock.npm : lock.jsr,
      spec,
    );

    if (pkg.dependencies) {
      for (const dep of pkg.dependencies) {
        const depSpecifier = spec.type === "npm" ? `npm:${dep}` : dep;
        resolveDependencies(depSpecifier);
      }
    }

    if (pkg.optionalDependencies) {
      for (const dep of pkg.optionalDependencies) {
        const depSpecifier = spec.type === "npm" ? `npm:${dep}` : dep;
        resolveDependencies(depSpecifier);
      }
    }
  }

  let hasNodeDependencies = false;
  const fileDependencies = new Set<string>();

  const graphs = await Promise.all(
    srcPaths.map((srcPath) =>
      createGraph(toFileUrl(resolve(srcPath)).href, {
        async load(specifier, isDynamic, _cacheSetting, checksum) {
          try {
            if (
              specifier.startsWith("node:") || specifier.startsWith("data:")
            ) {
              return {
                kind: "external",
                specifier,
              };
            }
            return await cacher.load(specifier, isDynamic, "only", checksum);
          } catch (error) {
            console.error("Failed to load", specifier, error);
            throw error;
          }
        },
        resolve(specifier, referrer) {
          try {
            const mapped = importMap.resolve(specifier, referrer);
            if (mapped.startsWith("npm:") || mapped.startsWith("jsr:")) {
              const resolved = stringifyPackageSpecifier(
                packageSpecifierResolver.resolve(mapped),
              );
              return resolved;
            }
            return mapped;
          } catch (error) {
            console.error(
              "Failed to resolve",
              specifier,
              "from",
              referrer,
              error,
            );
            throw error;
          }
        },
      })
    ),
  );

  for (const graph of graphs) {
    for (const mod of graph.modules) {
      if (mod.error) {
        throw new Error(
          `Failed resolving from cache ${mod.specifier}: ${mod.error}`,
        );
      }

      if (mod.dependencies) {
        for (const dep of mod.dependencies) {
          if (dep.code?.error !== undefined) {
            throw new Error(
              `Failed resolving ${dep.specifier}: ${dep.code.error}`,
            );
          }

          if (!hasNodeDependencies && dep.specifier.startsWith("node:")) {
            hasNodeDependencies = true;
          }
        }
      }

      if (mod.kind === "esm" && mod.specifier.startsWith("file:")) {
        fileDependencies.add(mod.specifier);
        continue;
      }

      if (
        mod.kind === "external" && mod.specifier.startsWith("npm:")
      ) {
        resolveDependencies(mod.specifier);
      }

      if (!hasNodeDependencies && mod.specifier.startsWith("node:")) {
        hasNodeDependencies = true;
      }
    }

    if (hasNodeDependencies) {
      resolveDependencies("npm:@types/node");
    }

    const graphPackages: Record<string, string> | undefined =
      // deno-lint-ignore no-explicit-any
      (graph as unknown as any).packages;

    if (graphPackages) {
      for (
        const p of Object.values(graphPackages)
      ) {
        resolveDependencies(`jsr:${p}`);
      }
    }
  }

  return {
    packageSpecifierResolver,
    fileDependencies,
  };
}
