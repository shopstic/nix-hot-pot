import { exists, walk } from "@std/fs";
import { AsyncQueue } from "@wok/utils/async-queue";
import { Logger } from "@wok/utils/logger";
import { gray } from "@std/fmt/colors";
import { toFileUrl } from "@std/path/to-file-url";
import { parseImportMapFromJson } from "./import_map.ts";
import { join } from "@std/path/join";
import { relative } from "@std/path/relative";
import { format as formatDuration } from "@std/fmt/duration";
import { extractModuleSpecifiers } from "./extract_specifiers.ts";
import { resolve } from "@std/path/resolve";

export async function extractExternalSpecifiers(
  { srcPath, denoConfigPath, logger }: {
    srcPath: string;
    denoConfigPath?: string;
    logger: Logger;
  },
): Promise<Set<string>> {
  const resolvedDenoConfigPath = denoConfigPath
    ? resolve(denoConfigPath)
    : join(srcPath, "deno.json");

  if (!(await exists(resolvedDenoConfigPath))) {
    throw new Error(`deno.json not found at ${resolvedDenoConfigPath}`);
  }

  const importMap = await parseImportMapFromJson(
    toFileUrl(resolvedDenoConfigPath),
    await Deno.readTextFile(resolvedDenoConfigPath),
    { expandImports: true },
  );

  const allSpecifiers = new Set<string>();
  const concurrency = 32;

  for await (
    const { fileUrl, specifiers } of AsyncQueue
      .from(walk(srcPath))
      .filter((entry) =>
        entry.isFile &&
        (entry.name.endsWith(".ts") || entry.name.endsWith(".tsx") ||
          entry.name.endsWith(".js") || entry.name.endsWith(".jsx"))
      )
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
