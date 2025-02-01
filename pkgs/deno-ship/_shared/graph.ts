import {
  createGraph as originalCreateGraph,
  CreateGraphOptions,
  ModuleGraphJson,
} from "@deno/graph";

export async function createGraph(
  rootSpecifiers: string | string[],
  options: CreateGraphOptions = {},
): Promise<ModuleGraphJson> {
  const DENO_WASM_CACHE_HOME = Deno.env.get("DENO_WASM_CACHE_HOME");

  if (DENO_WASM_CACHE_HOME !== undefined) {
    Deno.env.set("HOME", DENO_WASM_CACHE_HOME);
    Deno.env.set("XDG_DATA_HOME", DENO_WASM_CACHE_HOME);
  }

  return await originalCreateGraph(rootSpecifiers, options);
}
