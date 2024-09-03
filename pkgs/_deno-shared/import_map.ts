import {
  ImportMap,
  type ImportMapJson,
  parseFromJson as originalParseFromJson,
} from "https://deno.land/x/import_map@v0.20.1/mod.ts";
export { ImportMap, type ImportMapJson };

export async function parseFromJson(
  baseUrl: string | URL,
  json: string | ImportMapJson,
  opts?: { expandImports?: boolean },
): Promise<ImportMap> {
  const DENO_WASM_CACHE_HOME = Deno.env.get("DENO_WASM_CACHE_HOME");

  if (!DENO_WASM_CACHE_HOME) {
    throw new Error("DENO_WASM_CACHE_HOME env var is not set");
  }

  Deno.env.set("HOME", DENO_WASM_CACHE_HOME);
  Deno.env.set("XDG_DATA_HOME", DENO_WASM_CACHE_HOME);

  return await originalParseFromJson(baseUrl, json, opts);
}
