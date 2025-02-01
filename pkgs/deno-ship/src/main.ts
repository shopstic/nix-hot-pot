import { CliProgram } from "@wok/utils/cli";
import { unmapSpecifiersAction } from "./actions/unmap_specifiers.ts";
import { genCacheEntryAction } from "./actions/gen_cache_entry.ts";
import { trimLockAction } from "./actions/trim_lock.ts";

await new CliProgram()
  .addAction("unmap-specifiers", unmapSpecifiersAction)
  .addAction("gen-cache-entry", genCacheEntryAction)
  .addAction("trim-lock", trimLockAction)
  .run(Deno.args);
