import {
  CliProgram,
} from "https://raw.githubusercontent.com/shopstic/deno-utils/1.10.0/src/cli_utils.ts";
import updateJdkTableXml from "./actions/update-jdk-table-xml.ts";

await new CliProgram()
  .addAction("update-jdk-table-xml", updateJdkTableXml)
  .run(Deno.args);

/* async function extractJmodList(homePath: string) {
  const jmods = [];

  for await (
    const file of expandGlob("*.jmod", {
      root: joinPath(homePath, "jmods"),
    })
  ) {
    if (file.isFile) {
      jmods.push(file.name.replace(/\.jmod$/, ""));
    }
  }

  return jmods;
}

async function extractSrcList(homePath: string) {
  const srcZipPath = joinPath(homePath, "lib/src.zip");

  try {
    const files = (await captureExec({
      run: {
        cmd: ["zipinfo", "-1", srcZipPath],
      },
    })).split("\n");

    const directories = files.map((f) => f.replace(/^([^\/]+)\/.+/, "$1"));
    return [...new Set(directories)];
  } catch (err) {
    if (err instanceof NonZeroExitError && err.exitCode === 9) {
      return [];
    }
    throw err;
  }
} */
