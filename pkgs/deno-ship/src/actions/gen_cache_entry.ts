import { createCliAction, ExitCode } from "@wok/utils/cli";
import { getDefaultLogger } from "@wok/utils/logger";
import { gray } from "@std/fmt/colors";
import { resolve } from "@std/path/resolve";
import { extractExternalSpecifiers } from "../lib/extract_external_specifiers.ts";
import { NonEmpStr, Opt, PosInt } from "@wok/schema";

export const genCacheEntryAction = createCliAction(
  {
    concurrency: Opt(PosInt(), 32),
    srcDir: NonEmpStr(),
    config: Opt(NonEmpStr()),
  },
  async ({ concurrency, srcDir, config }) => {
    const logger = getDefaultLogger().prefixed(gray("main"));
    const resolvedSrcPath = resolve(srcDir);

    logger.info?.(
      "Generating cache entry for",
      resolvedSrcPath,
      "using concurrency:",
      concurrency,
    );

    const allSpecifiers = Array.from(
      await extractExternalSpecifiers({
        srcPath: resolvedSrcPath,
        denoConfigPath: config,
        logger,
      }),
    );

    const sorted = allSpecifiers.sort();

    for (const specifier of sorted) {
      console.log(`import ${JSON.stringify(specifier)};`);
    }

    return ExitCode.Zero;
  },
);
