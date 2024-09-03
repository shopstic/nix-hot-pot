import { assert } from "@std/assert/assert";
import { foo } from "../../foo.ts";
export * from "@std/assert/exists";

assert(foo === "bar");
