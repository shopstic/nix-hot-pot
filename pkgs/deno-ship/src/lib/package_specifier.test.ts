import { assertEquals } from "@std/assert";
import {
  type PackageSpecifier,
  parsePackageSpecifier,
  stringifyPackageSpecifier,
} from "./package_specifier.ts";

function pkg(
  spec: { type: "npm" | "jsr"; name: string; version?: string; path?: string },
): PackageSpecifier {
  return spec as PackageSpecifier;
}
Deno.test("parsePackageSpecifier() - valid", () => {
  const tests: Array<{ input: string; expected: PackageSpecifier }> = [
    {
      input: "npm:/@foo/bar",
      expected: pkg({
        type: "npm",
        name: "@foo/bar",
        version: undefined,
        path: undefined,
      }),
    },
    {
      input: "npm:@foo/bar",
      expected: pkg({
        type: "npm",
        name: "@foo/bar",
        version: undefined,
        path: undefined,
      }),
    },
    {
      input: "npm:@foo/bar@^1.2.3",
      expected: pkg({
        type: "npm",
        name: "@foo/bar",
        version: "^1.2.3",
        path: undefined,
      }),
    },
    {
      input: "npm:@foo/bar@^1.2.3/baz/boo",
      expected: pkg({
        type: "npm",
        name: "@foo/bar",
        version: "^1.2.3",
        path: "baz/boo",
      }),
    },
    {
      input: "jsr:/foo",
      expected: pkg({
        type: "jsr",
        name: "foo",
        version: undefined,
        path: undefined,
      }),
    },
    {
      input: "jsr:foo@1.2.3",
      expected: pkg({
        type: "jsr",
        name: "foo",
        version: "1.2.3",
        path: undefined,
      }),
    },
    {
      input: "jsr:foo@1.2.3/bar",
      expected: pkg({
        type: "jsr",
        name: "foo",
        version: "1.2.3",
        path: "bar",
      }),
    },
    {
      input: "npm:foo",
      expected: pkg({
        type: "npm",
        name: "foo",
        version: undefined,
        path: undefined,
      }),
    },
    {
      input: "npm:foo@1.2.3",
      expected: pkg({
        type: "npm",
        name: "foo",
        version: "1.2.3",
        path: undefined,
      }),
    },
    {
      input: "jsr:foo",
      expected: pkg({
        type: "jsr",
        name: "foo",
        version: undefined,
        path: undefined,
      }),
    },
  ];

  for (const { input, expected } of tests) {
    const result = parsePackageSpecifier(input);
    assertEquals(result, expected, `Failed for input: ${input}`);
  }
});

Deno.test("parsePackageSpecifier() - invalid", () => {
  const invalidInputs = [
    "@foo/bar", // Missing scheme
    "foo@1.2.3", // Missing scheme
    "npm:", // Scheme with no package name
    "jsr:", // Scheme with no package name
    "npm:/", // Scheme with only a slash
    "jsr:/", // Scheme with only a slash
    "npm:@foo", // Scoped package missing the slash separator
    "jsr:foo@", // Trailing '@' with no version
    "npm:foo@1.2.3/", // Trailing slash with empty path
    "npm:Foo", // Package name contains uppercase characters (invalid)
  ];

  for (const input of invalidInputs) {
    assertEquals(
      parsePackageSpecifier(input),
      undefined,
      `Failed for input: ${input}`,
    );
  }
});

Deno.test("stringifyPackageSpecifier()", () => {
  const tests: Array<{ spec: PackageSpecifier; expected: string }> = [
    {
      spec: pkg({ type: "npm", name: "@foo/bar" }),
      expected: "npm:@foo/bar",
    },
    {
      spec: pkg({ type: "npm", name: "@foo/bar", version: "^1.2.3" }),
      expected: "npm:@foo/bar@^1.2.3",
    },
    {
      spec: pkg({
        type: "npm",
        name: "@foo/bar",
        version: "^1.2.3",
        path: "baz/boo",
      }),
      expected: "npm:@foo/bar@^1.2.3/baz/boo",
    },
    {
      spec: pkg({ type: "jsr", name: "foo" }),
      expected: "jsr:foo",
    },
    {
      spec: pkg({ type: "jsr", name: "foo", version: "1.2.3" }),
      expected: "jsr:foo@1.2.3",
    },
    {
      spec: pkg({ type: "jsr", name: "foo", version: "1.2.3", path: "bar" }),
      expected: "jsr:foo@1.2.3/bar",
    },
  ];

  for (const { spec, expected } of tests) {
    const result = stringifyPackageSpecifier(spec);
    assertEquals(result, expected, `Failed for spec: ${JSON.stringify(spec)}`);
  }
});
