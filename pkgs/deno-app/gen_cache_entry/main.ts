import { CliProgram, createCliAction, ExitCode } from "@wok/utils/cli";
import { NonEmptyString, PosInt, Type } from "@wok/typebox";
import { getDefaultLogger } from "@wok/utils/logger";
import { gray } from "@std/fmt/colors";
import { resolve } from "@std/path/resolve";
import { extractExternalSpecifiers } from "$shared/extract_external_specifiers.ts";

const logger = getDefaultLogger().prefixed(gray("main"));

const run = createCliAction(
  {
    concurrency: Type.Optional(PosInt({ default: 32 })),
    srcPath: NonEmptyString(),
  },
  async ({ concurrency = 32, srcPath }) => {
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

await new CliProgram()
  .addAction("gen", run)
  .run(Deno.args);
