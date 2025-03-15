import { resolve, toFileUrl } from "@std/path";
import { DenoDir } from "@deno/cache-dir";
import { parseImportMapFromJson } from "../lib/import_map.ts";
import { createCliAction, ExitCode } from "@wok/utils/cli";
import { Arr, NonEmpStr, Opt } from "@wok/schema/schema";
import {
  buildPackageSpecifierResolver,
  DenoLock,
  PackageSpecifierResolver,
} from "../lib/package_specifier_resolver.ts";

export function trimLock({ packageSpecifierResolver, lock }: {
  packageSpecifierResolver: PackageSpecifierResolver;
  lock: DenoLock;
}) {
  return {
    ...lock,
    specifiers: Object.fromEntries(
      Object.entries(lock.specifiers).filter(([key]) =>
        packageSpecifierResolver.cache.has(key)
      ),
    ),
    jsr: Object.fromEntries(
      Object.entries(lock.jsr).filter(([key]) =>
        packageSpecifierResolver.cache.has(`jsr:${key}`)
      ),
    ),
    npm: Object.fromEntries(
      Object.entries(lock.npm).filter(([key]) =>
        packageSpecifierResolver.cache.has(`npm:${key}`)
      ),
    ),
  };
}

export const trimLockAction = createCliAction(
  {
    denoDir: Opt(
      NonEmpStr({
        description: "Path to the deno cache directory. Defaults to $DENO_DIR",
      }),
    ),
    config: NonEmpStr({
      description: "Path to the import map (deno.json)",
      examples: ["./deno.json"],
    }),
    lock: NonEmpStr({
      description: "Path to the lock file (deno.lock)",
      examples: ["./deno.lock"],
    }),
    _: Arr(NonEmpStr(), {
      minItems: 1,
      description: "One or more paths to source files",
      title: "files",
      examples: [["./src/foo.ts", "./src/bar.ts"]],
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
    const resolvedConfigPath = resolve(configPath);
    const resolvedLockPath = resolve(lockPath);
    const lock: DenoLock = JSON.parse(
      await Deno.readTextFile(resolvedLockPath),
    );
    const denoDir = new DenoDir(denoDirPath);
    const importMap = await parseImportMapFromJson(
      toFileUrl(resolvedConfigPath),
      await Deno.readTextFile(resolvedConfigPath),
      {
        expandImports: true,
      },
    );

    const { packageSpecifierResolver } = await buildPackageSpecifierResolver({
      denoDir,
      importMap,
      lock,
      srcPaths,
    });

    console.error(
      JSON.stringify(
        Object.fromEntries(
          Array
            .from(packageSpecifierResolver.cache.entries())
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([specifier, resolved]) => [specifier, resolved.version]),
        ),
        null,
        2,
      ),
    );
    console.log(JSON.stringify(
      trimLock({
        packageSpecifierResolver,
        lock,
      }),
      null,
      2,
    ));

    return ExitCode.Zero;
  },
);
