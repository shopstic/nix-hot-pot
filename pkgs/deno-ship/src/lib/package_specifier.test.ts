import { assertEquals } from "@std/assert";
import {
  type PackageSpecifier,
  PackageType,
  parsePackageSpecifier,
  stringifyPackageSpecifier,
} from "./package_specifier.ts";

function pkg(
  { type, name, version, path }: {
    type: "npm" | "jsr";
    name: string;
    version?: string;
    path?: string;
  },
): PackageSpecifier {
  return { type, name, version, path } as PackageSpecifier;
}

function testParsePackageSpecifier(
  input: string,
  expected: PackageSpecifier | undefined,
  providedType?: PackageType,
): void {
  const result = parsePackageSpecifier(input, providedType);
  assertEquals(
    result,
    expected,
    `Failed for input: "${input}" with provided type: ${
      providedType ?? "none"
    }`,
  );
}

Deno.test("parsePackageSpecifier() - valid without provided type", () => {
  testParsePackageSpecifier(
    "npm:/@foo/bar",
    pkg({ type: "npm", name: "@foo/bar" }),
  );
  testParsePackageSpecifier(
    "npm:@foo/bar",
    pkg({ type: "npm", name: "@foo/bar" }),
  );
  testParsePackageSpecifier(
    "npm:@foo/bar@^1.2.3",
    pkg({ type: "npm", name: "@foo/bar", version: "^1.2.3" }),
  );
  testParsePackageSpecifier(
    "npm:@foo/bar@^1.2.3/baz/boo",
    pkg({ type: "npm", name: "@foo/bar", version: "^1.2.3", path: "baz/boo" }),
  );
  testParsePackageSpecifier("jsr:/foo", pkg({ type: "jsr", name: "foo" }));
  testParsePackageSpecifier(
    "jsr:foo@1.2.3",
    pkg({ type: "jsr", name: "foo", version: "1.2.3" }),
  );
  testParsePackageSpecifier(
    "jsr:foo@1.2.3/bar",
    pkg({ type: "jsr", name: "foo", version: "1.2.3", path: "bar" }),
  );
  testParsePackageSpecifier("npm:foo", pkg({ type: "npm", name: "foo" }));
  testParsePackageSpecifier(
    "npm:foo@1.2.3",
    pkg({ type: "npm", name: "foo", version: "1.2.3" }),
  );
  testParsePackageSpecifier("jsr:foo", pkg({ type: "jsr", name: "foo" }));
});

Deno.test("parsePackageSpecifier() - valid with provided type", () => {
  // When a PackageType is provided, the input should not include a scheme.
  testParsePackageSpecifier(
    "@foo/bar",
    pkg({ type: "npm", name: "@foo/bar" }),
    "npm",
  );
  testParsePackageSpecifier("foo", pkg({ type: "jsr", name: "foo" }), "jsr");
  testParsePackageSpecifier(
    "foo@1.2.3",
    pkg({ type: "npm", name: "foo", version: "1.2.3" }),
    "npm",
  );
  testParsePackageSpecifier(
    "foo@1.2.3/bar",
    pkg({ type: "jsr", name: "foo", version: "1.2.3", path: "bar" }),
    "jsr",
  );
  testParsePackageSpecifier(
    "@foo/bar@latest/baz",
    pkg({ type: "npm", name: "@foo/bar", version: "latest", path: "baz" }),
    "npm",
  );
});

Deno.test("parsePackageSpecifier() - invalid without provided type", () => {
  testParsePackageSpecifier("@foo/bar", undefined);
  testParsePackageSpecifier("foo@1.2.3", undefined);
  testParsePackageSpecifier("npm:", undefined);
  testParsePackageSpecifier("jsr:", undefined);
  testParsePackageSpecifier("npm:/", undefined);
  testParsePackageSpecifier("jsr:/", undefined);
  testParsePackageSpecifier("npm:@foo", undefined);
  testParsePackageSpecifier("jsr:foo@", undefined);
  testParsePackageSpecifier("npm:foo@1.2.3/", undefined);
  testParsePackageSpecifier("npm:Foo", undefined);
});

Deno.test("parsePackageSpecifier() - invalid with provided type", () => {
  // When a provided type is passed, the input must not include a scheme.
  testParsePackageSpecifier("npm:@foo/bar", undefined, "npm");
  testParsePackageSpecifier("", undefined, "jsr");
  testParsePackageSpecifier("/", undefined, "npm");
  testParsePackageSpecifier("Foo", undefined, "npm");
  testParsePackageSpecifier("foo@", undefined, "jsr");
  testParsePackageSpecifier("foo@/bar", undefined, "npm");
});

function testStringifyPackageSpecifier(
  spec: PackageSpecifier,
  expected: string,
): void {
  const result = stringifyPackageSpecifier(spec);
  assertEquals(
    result,
    expected,
    `Failed for spec: ${JSON.stringify(spec)}`,
  );
}

Deno.test("stringifyPackageSpecifier() - valid cases", () => {
  // Basic valid cases.
  testStringifyPackageSpecifier(
    pkg({ type: "npm", name: "@foo/bar" }),
    "npm:@foo/bar",
  );
  testStringifyPackageSpecifier(
    pkg({ type: "npm", name: "@foo/bar", version: "^1.2.3" }),
    "npm:@foo/bar@^1.2.3",
  );
  testStringifyPackageSpecifier(
    pkg({ type: "npm", name: "@foo/bar", version: "^1.2.3", path: "baz/boo" }),
    "npm:@foo/bar@^1.2.3/baz/boo",
  );
  testStringifyPackageSpecifier(pkg({ type: "jsr", name: "foo" }), "jsr:foo");
  testStringifyPackageSpecifier(
    pkg({ type: "jsr", name: "foo", version: "1.2.3" }),
    "jsr:foo@1.2.3",
  );
  testStringifyPackageSpecifier(
    pkg({ type: "jsr", name: "foo", version: "1.2.3", path: "bar" }),
    "jsr:foo@1.2.3/bar",
  );

  // Additional valid cases when type is provided.
  testStringifyPackageSpecifier(
    pkg({ type: "npm", name: "foo", path: "bar" }),
    "npm:foo/bar",
  );
  testStringifyPackageSpecifier(
    pkg({ type: "jsr", name: "foo", path: "baz" }),
    "jsr:foo/baz",
  );

  // Negative cases:
  // When version is an empty string, it should not add the "@".
  testStringifyPackageSpecifier(
    pkg({ type: "npm", name: "foo", version: "", path: "bar" }),
    "npm:foo/bar",
  );
  // When path is an empty string, it should not add the "/" at the end.
  testStringifyPackageSpecifier(
    pkg({ type: "jsr", name: "foo", version: "1.2.3", path: "" }),
    "jsr:foo@1.2.3",
  );
});
