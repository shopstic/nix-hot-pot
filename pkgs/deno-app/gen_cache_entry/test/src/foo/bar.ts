import { memoize } from "@wok/utils/memoize";
export * from "jsr:@std/fmt/colors";

export const foo = memoize(() => {
  console.log("foo");
});
