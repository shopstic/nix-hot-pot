import { exists, walk } from "@std/fs";
import { AsyncQueue } from "@wok/utils/async-queue";
import { Logger } from "@wok/utils/logger";
import { gray } from "@std/fmt/colors";
import { toFileUrl } from "@std/path/to-file-url";
import { parseImportMapFromJson } from "$shared/import_map.ts";
import { join } from "@std/path/join";
import { relative } from "@std/path/relative";
import { format as formatDuration } from "@std/fmt/duration";
import { extractModuleSpecifiers } from "$shared/extract_specifiers.ts";

export async function extractExternalSpecifiers(
  { srcPath, logger }: {
    srcPath: string;
    logger: Logger;
  },
): Promise<Set<string>> {
  const denoConfigPath = join(srcPath, "deno.json");

  if (!(await exists(denoConfigPath))) {
    throw new Error(`deno.json not found at ${denoConfigPath}`);
  }

  const importMap = await parseImportMapFromJson(
    toFileUrl(denoConfigPath),
    await Deno.readTextFile(denoConfigPath),
    { expandImports: true },
  );

  const allSpecifiers = new Set<string>();
  const concurrency = 32;

  for await (
    const { fileUrl, specifiers } of AsyncQueue
      .from(walk(srcPath))
      .filter((entry) => entry.isFile && entry.name.endsWith(".ts"))
      .concurrentMap(concurrency, async (entry) => {
        const filePath = entry.path;
        const startTime = performance.now();
        const specifierSet = extractModuleSpecifiers(
          filePath,
          await Deno.readTextFile(filePath),
        );
        logger.info?.(
          "extracted:",
          relative(srcPath, filePath),
          "specifiers:",
          specifierSet.size,
          gray(
            formatDuration(performance.now() - startTime, {
              ignoreZero: true,
            }),
          ),
        );

        return {
          fileUrl: toFileUrl(entry.path),
          specifiers: specifierSet,
        };
      })
  ) {
    for (const specifier of specifiers) {
      const resolved = importMap.resolve(specifier, fileUrl);
      if (
        resolved.startsWith("file://") || resolved.startsWith("node:") ||
        resolved.startsWith("data:")
      ) {
        continue;
      }
      allSpecifiers.add(resolved);
    }
  }

  return allSpecifiers;
}
