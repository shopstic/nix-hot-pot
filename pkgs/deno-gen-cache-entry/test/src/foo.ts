import { inheritExec } from "@wok/utils/exec";
await inheritExec({
  cmd: ["echo", "1"],
});

export const foo: string = "foo";
