import { createCliAction, ExitCode } from "@wok/utils/cli";
import { getDefaultLogger } from "@wok/utils/logger";
import { gray } from "@std/fmt/colors";
import { resolve } from "@std/path/resolve";
import { extractExternalSpecifiers } from "../../_shared/extract_external_specifiers.ts";
import { NonEmpStr, Opt, PosInt } from "@wok/schema";

export const genCacheEntryAction = createCliAction(
  {
    concurrency: Opt(PosInt(), 32),
    srcPath: NonEmpStr(),
    denoConfigPath: Opt(NonEmpStr()),
  },
  async ({ concurrency, srcPath, denoConfigPath }) => {
    const logger = getDefaultLogger().prefixed(gray("main"));
    const resolvedSrcPath = resolve(srcPath);

    logger.info?.(
      "Generating cache entry for",
      resolvedSrcPath,
      "using concurrency:",
      concurrency,
    );

    const allSpecifiers = Array.from(
      await extractExternalSpecifiers({
        srcPath: resolvedSrcPath,
        denoConfigPath,
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
