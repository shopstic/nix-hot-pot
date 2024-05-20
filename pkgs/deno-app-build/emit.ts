import {
  transpile as originalTranspile,
  type TranspileOptions,
} from "jsr:@deno/emit@0.40.2";
export { type TranspileOptions };

export async function transpile(
  root: string | URL,
  options: TranspileOptions = {},
) {
  const DENO_EMIT_WASM_CACHE_HOME = Deno.env.get("DENO_EMIT_WASM_CACHE_HOME");

  if (!DENO_EMIT_WASM_CACHE_HOME) {
    throw new Error("DENO_EMIT_WASM_CACHE_HOME env var is not set");
  }

  Deno.env.set("HOME", DENO_EMIT_WASM_CACHE_HOME);
  Deno.env.set("XDG_DATA_HOME", DENO_EMIT_WASM_CACHE_HOME);
  return await originalTranspile(root, options);
}
