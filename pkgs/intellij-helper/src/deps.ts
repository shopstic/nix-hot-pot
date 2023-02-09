export {
  parse as parseXml,
  stringify as stringifyXml,
} from "https://deno.land/x/xml@2.1.0/mod.ts";
export { join as joinPath } from "https://deno.land/std@0.172.0/path/mod.ts";
export { validate } from "https://deno.land/x/utils@2.10.0/validation_utils.ts";
export { Type } from "https://deno.land/x/utils@2.10.0/deps/typebox.ts";
import immerProduce from "https://esm.sh/immer@9.0.19?pin=v106";

export {
  CliProgram,
  createCliAction,
  ExitCode,
} from "https://deno.land/x/utils@2.10.0/cli_utils.ts";
export { immerProduce };
