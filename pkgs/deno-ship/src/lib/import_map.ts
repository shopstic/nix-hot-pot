import {
  ImportMap,
  type ImportMapJson,
  parseFromJson,
} from "https://deno.land/x/import_map@v0.21.0/mod.ts";
export { ImportMap, type ImportMapJson };

export async function parseImportMapFromJson(
  baseUrl: string | URL,
  json: string | ImportMapJson,
  opts?: { expandImports?: boolean },
): Promise<ImportMap> {
  const DENO_WASM_CACHE_HOME = Deno.env.get("DENO_WASM_CACHE_HOME");

  if (DENO_WASM_CACHE_HOME !== undefined) {
    Deno.env.set("HOME", DENO_WASM_CACHE_HOME);
    Deno.env.set("XDG_DATA_HOME", DENO_WASM_CACHE_HOME);
  }

  return await parseFromJson(baseUrl, json, opts);
}
