export {
  parse as parseXml,
  stringify as stringifyXml,
} from "https://deno.land/x/xml@2.0.3/mod.ts";
export { join as joinPath } from "https://deno.land/std@0.119.0/path/mod.ts";
export { validate } from "https://deno.land/x/utils@2.0.3/validation_utils.ts";
export { Type } from "https://deno.land/x/utils@2.0.3/deps/typebox.ts";
// @deno-types="https://cdn.shopstic.com/pin/immer@v9.0.7-x2CHFftUbIlt09HPl5Vq/dist=es2020,mode=types/dist/immer.d.ts"
import immerProduce from "https://cdn.shopstic.com/pin/immer@v9.0.7-x2CHFftUbIlt09HPl5Vq/dist=es2020,mode=imports/optimized/immer.js";

export {
  CliProgram,
  createCliAction,
  ExitCode,
} from "https://deno.land/x/utils@2.0.3/cli_utils.ts";
export { immerProduce };
