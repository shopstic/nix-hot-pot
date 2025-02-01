import { CliProgram, createCliAction, ExitCode } from "@wok/utils/cli";
import { unmapSpecifiersAction } from "./actions/unmap_specifiers.ts";
import { genCacheEntryAction } from "./actions/gen_cache_entry.ts";
import { trimLockAction } from "./actions/trim_lock.ts";
import { parseImportMapFromJson } from "$shared/import_map.ts";
import { transpile } from "$shared/transpile.ts";

await new CliProgram()
  .addAction("unmap-specifiers", unmapSpecifiersAction)
  .addAction("gen-cache-entry", genCacheEntryAction)
  .addAction("trim-lock", trimLockAction)
  .addAction(
    "cache-wasm",
    createCliAction({}, async () => {
      try {
        await parseImportMapFromJson("", "");
      } catch {
        // Ignore
      }

      try {
        await transpile("");
      } catch {
        // Ignore
      }

      return ExitCode.Zero;
    }),
  )
  .run(Deno.args);
