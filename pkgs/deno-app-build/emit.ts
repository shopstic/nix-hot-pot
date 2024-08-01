import {
  transpile as originalTranspile,
  type TranspileOptions,
} from "@deno/emit";
export { type TranspileOptions };

export async function transpile(
  root: string | URL,
  options: TranspileOptions = {},
) {
  const DENO_WASM_CACHE_HOME = Deno.env.get("DENO_WASM_CACHE_HOME");

  if (!DENO_WASM_CACHE_HOME) {
    throw new Error("DENO_WASM_CACHE_HOME env var is not set");
  }

  Deno.env.set("HOME", DENO_WASM_CACHE_HOME);
  Deno.env.set("XDG_DATA_HOME", DENO_WASM_CACHE_HOME);
  return await originalTranspile(root, options);
}
