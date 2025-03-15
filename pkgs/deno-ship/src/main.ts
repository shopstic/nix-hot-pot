import { CliProgram, createCliAction, ExitCode } from "@wok/utils/cli";
import { unmapSpecifiersAction } from "./actions/unmap_specifiers.ts";
import { genCacheEntryAction } from "./actions/gen_cache_entry.ts";
import { trimLockAction } from "./actions/trim_lock.ts";
import { parseImportMapFromJson } from "./lib/import_map.ts";
import { createGraph } from "./lib/graph.ts";
import { stageAction } from "./actions/stage.ts";

await new CliProgram()
  .addAction("unmap-specifiers", unmapSpecifiersAction)
  .addAction("gen-cache-entry", genCacheEntryAction)
  .addAction("trim-lock", trimLockAction)
  .addAction("stage", stageAction)
  .addAction(
    "cache-wasm",
    createCliAction({}, async () => {
      await Promise.allSettled([
        parseImportMapFromJson("", ""),
        createGraph(""),
      ]);

      return ExitCode.Zero;
    }),
  )
  .run(Deno.args);
