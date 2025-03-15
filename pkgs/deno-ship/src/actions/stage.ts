import { fromFileUrl, join, resolve, toFileUrl } from "@std/path";
import { DenoDir } from "@deno/cache-dir";
import { parseImportMapFromJson } from "../lib/import_map.ts";
import { createCliAction, ExitCode } from "@wok/utils/cli";
import { Arr, NonEmpStr, Opt } from "@wok/schema/schema";
import {
  buildPackageSpecifierResolver,
  DenoLock,
} from "../lib/package_specifier_resolver.ts";
import { trimLock } from "./trim_lock.ts";
import { relative } from "@std/path/relative";
import { dirname } from "@std/path/dirname";
import { Semaphore } from "@wok/utils/semaphore";

export const stageAction = createCliAction(
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
    outDir: NonEmpStr({
      description: "Path to the output directory for staged files",
      examples: ["./staged"],
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
      outDir,
      denoDir: denoDirPath,
      config: configPath,
      lock: lockPath,
      _: srcPaths,
    },
  ) => {
    const resolvedOutDir = resolve(outDir);
    const resolvedConfigPath = resolve(configPath);
    const resolvedLockPath = resolve(lockPath);
    const lock: DenoLock = JSON.parse(
      await Deno.readTextFile(resolvedLockPath),
    );
    const denoDir = new DenoDir(denoDirPath);
    const denoJson = await Deno.readTextFile(resolvedConfigPath);
    const importMap = await parseImportMapFromJson(
      toFileUrl(resolvedConfigPath),
      denoJson,
      {
        expandImports: true,
      },
    );

    console.error("resolving dependencies");
    const { packageSpecifierResolver, fileDependencies } =
      await buildPackageSpecifierResolver({
        denoDir,
        importMap,
        lock,
        srcPaths,
      });

    const trimmedLock = trimLock({
      packageSpecifierResolver,
      lock,
    });

    const rootPath = dirname(resolvedConfigPath);
    const toCopy = fileDependencies.values().toArray().map((file) => {
      const from = fromFileUrl(file);
      const to = join(resolvedOutDir, relative(rootPath, fromFileUrl(file)));
      return { from, to, dir: dirname(to) };
    });

    const dirSet = [...new Set(toCopy.map(({ dir }) => dir))].sort();

    for (const dir of dirSet) {
      await Deno.mkdir(dir, { recursive: true });
    }

    const semaphore = new Semaphore(32);

    await Promise.all(
      toCopy.map(async ({ from, to }) => {
        await semaphore.acquire();
        try {
          console.error("copying", from, "to", to);
          await Deno.copyFile(from, to);
        } finally {
          semaphore.release();
        }
      }),
    );

    console.error("writing trimmed lock file");
    await Deno.writeTextFile(
      join(resolvedOutDir, "deno.lock"),
      JSON.stringify(trimmedLock, null, 2),
    );

    console.error("writing deno.json");
    await Deno.writeTextFile(
      join(resolvedOutDir, "deno.json"),
      denoJson,
    );

    return ExitCode.Zero;
  },
);
