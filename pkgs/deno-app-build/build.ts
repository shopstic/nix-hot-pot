import { transpile, type TranspileOptions } from "./emit.ts";
import {
  dirname,
  fromFileUrl,
  join,
  relative,
  resolve,
  toFileUrl,
} from "jsr:@std/path@0.221.0";
import ts from "https://esm.sh/typescript@5.5.4";
import { assert } from "jsr:@std/assert@1.0.0";
import { exists } from "jsr:@std/fs@0.229.3";
import { parseArgs } from "jsr:@std/cli@1.0.0/parse-args";
import { inheritExec } from "jsr:@wok/utils@1.3.3/exec";
import {
  NonEmptyString,
  Static,
  Type,
  TypeGuard,
  Value,
} from "jsr:@wok/utils@1.3.3/typebox";
import { paramCase } from "jsr:@wok/case@1.0.1/param-case";
import { Semaphore } from "jsr:@wok/utils@1.3.3/semaphore";
import { parseFromJson } from "./import_map.ts";

const argsSchema = {
  _: Type.Array(Type.String()),
  allowNpmSpecifier: Type.Optional(Type.Boolean()),
  appPath: NonEmptyString(),
  outPath: NonEmptyString(),
};

const argToParamCaseMap: Map<string, string> = new Map(
  Object.keys(argsSchema).map((
    key,
  ) => [key, key !== "_" ? paramCase(key) : key]),
);

const argFromParamCaseMap: Map<string, string> = new Map(
  Array.from(argToParamCaseMap.entries()).map(([key, value]) => [value, key]),
);

const ParamCaseArgsSchema = Type.Object(Object.fromEntries(
  Object.entries(argsSchema).map((
    [key, value],
  ) => [argToParamCaseMap.get(key)!, value]),
));

const ArgsSchema = Type.Object(argsSchema);
type Args = Static<typeof ArgsSchema>;

const parsedArgs = Value.Convert(
  ParamCaseArgsSchema,
  parseArgs(Deno.args, {
    collect: Object.entries(ParamCaseArgsSchema.properties)
      .filter(([_, value]) => TypeGuard.IsArray(value))
      .map(([key]) => key),
  }),
);

if (!Value.Check(ParamCaseArgsSchema, parsedArgs)) {
  const errors = Value.Errors(ParamCaseArgsSchema, parsedArgs);
  console.error(
    "Invalid CLI arguments\n" +
      Array.from(errors).map((e) =>
        `  - ${e.path.replace(/^\//, "")}: Invalid value ${
          JSON.stringify(e.value)
        }. ${e.message}`
      ).join("\n"),
  );
  Deno.exit(1);
}

const paramCaseArgs = Value.Decode(ParamCaseArgsSchema, parsedArgs);
const args = Object.fromEntries(
  Object.entries(paramCaseArgs).map((
    [key, value],
  ) => [argFromParamCaseMap.get(key) ?? key, value]),
) as Args;

const { allowNpmSpecifier = false, appPath, outPath } = args;

function isRelativePath(path: string) {
  return path.startsWith("./") || path.startsWith("../");
}

const absoluteAppPath = resolve(appPath);
const absoluteOutPath = resolve(outPath);
const outToAppRelativePath = relative(absoluteAppPath, absoluteOutPath);
const rootPath = Deno.cwd();
const vendorDir = resolve(rootPath, ".vendor");

let backupDenoJson: string | undefined;
if (await exists(join(rootPath, "deno.json"))) {
  backupDenoJson = await Deno.readTextFile(join(rootPath, "deno.json"));
}

try {
  await inheritExec({
    cmd: [
      "deno",
      "vendor",
      "--node-modules-dir=false",
      `--output=${vendorDir}`,
      absoluteAppPath,
    ],
  });

  if (backupDenoJson !== undefined) {
    try {
      await Deno.writeTextFile(join(rootPath, "deno.json"), backupDenoJson);
    } catch {
      // Ignore
    }
  }

  const importMapUrl = toFileUrl(join(vendorDir, "import_map.json"));
  const hasImportMap = await exists(importMapUrl);

  type Load = NonNullable<TranspileOptions["load"]>;
  type LoadParams = Parameters<Load>;
  const sem = new Semaphore(32);

  const attemptToTranspile = async (): Promise<Map<string, string>> => {
    return await transpile(absoluteAppPath, {
      importMap: hasImportMap ? importMapUrl : undefined,
      cacheSetting: "only",
      allowRemote: false,
      async load(
        specifier: string,
        _isDynamic?: boolean,
        _cacheSetting?: LoadParams[2],
        _checksum?: string,
      ) {
        if (
          specifier.startsWith("node:") ||
          (allowNpmSpecifier && specifier.startsWith("npm:"))
        ) {
          return {
            kind: "external",
            specifier,
          };
        }

        await sem.acquire();
        try {
          const filePath = fromFileUrl(specifier);
          const content = await Deno.readTextFile(filePath);

          return {
            kind: "module",
            specifier,
            content,
          };
        } finally {
          sem.release();
        }
      },
    });
  };

  const result = await attemptToTranspile();

  const importMap = hasImportMap
    ? await parseFromJson(
      importMapUrl,
      await Deno.readTextFile(importMapUrl),
    )
    : undefined;

  const toCopyAssetFiles: string[] = [];

  const rewriteModuleSpecifier = (path: string, specifier: string) => {
    if (
      importMap &&
      !isRelativePath(specifier) &&
      !specifier.startsWith("node:") &&
      !(allowNpmSpecifier && specifier.startsWith("npm:"))
    ) {
      const parentPath = dirname(path);
      const resolved = importMap.resolve(specifier, toFileUrl(path));

      const resolvedRelative = relative(parentPath, fromFileUrl(resolved))
        .replace(/\.ts$/, ".js");

      if (!isRelativePath(resolvedRelative)) {
        return `./${resolvedRelative}`;
      }

      return resolvedRelative;
    }

    if (isRelativePath(specifier) && specifier.endsWith(".json")) {
      toCopyAssetFiles.push(
        resolve(outToAppRelativePath, resolve(dirname(path), specifier)),
      );
    }

    return specifier.replace(/\.ts$/, ".js");
  };

  const transformFile = (filePath: string, sourceCode: string) => {
    const sourceFile = ts.createSourceFile(
      filePath,
      sourceCode,
      ts.ScriptTarget.Latest,
      true,
    );

    const transformer: ts.TransformerFactory<ts.SourceFile> = (
      ctx: ts.TransformationContext,
    ) => {
      const { factory } = ctx;
      return (sourceFile: ts.SourceFile) => {
        function visit(node: ts.Node): ts.Node {
          if (ts.isImportDeclaration(node)) {
            if (
              node.moduleSpecifier && ts.isStringLiteral(node.moduleSpecifier)
            ) {
              return factory.updateImportDeclaration(
                node,
                node.modifiers,
                node.importClause,
                factory.createStringLiteral(
                  rewriteModuleSpecifier(filePath, node.moduleSpecifier.text),
                ),
                node.attributes,
              );
            }

            return node;
          }

          if (ts.isExportDeclaration(node)) {
            if (
              node.moduleSpecifier && ts.isStringLiteral(node.moduleSpecifier)
            ) {
              return factory.updateExportDeclaration(
                node,
                node.modifiers,
                node.isTypeOnly,
                node.exportClause,
                factory.createStringLiteral(
                  rewriteModuleSpecifier(filePath, node.moduleSpecifier.text),
                ),
                node.attributes,
              );
            }

            return node;
          }

          return ts.visitEachChild(node, visit, ctx);
        }

        const ret = ts.visitNode(sourceFile, visit);
        assert(ts.isSourceFile(ret));
        return ret;
      };
    };

    const ret = ts.transform(sourceFile, [transformer]);
    assert(ret.transformed.length === 1);
    const printer = ts.createPrinter({ newLine: ts.NewLineKind.LineFeed });
    return printer.printFile(ret.transformed[0]);
  };

  const promises = Array.from(result).map(async ([key, content]) => {
    const path = fromFileUrl(key);
    const newPath = join(
      absoluteOutPath,
      relative(rootPath, path).replace(/\.ts$/, ".js"),
    );
    const newParentDir = dirname(newPath);
    await sem.acquire();
    try {
      await Deno.mkdir(newParentDir, { recursive: true });
      await Deno.writeTextFile(newPath, transformFile(path, content));
    } finally {
      sem.release();
    }
    console.error(`Wrote ${newPath}`);
  });
  await Promise.all(promises);

  if (toCopyAssetFiles.length > 0) {
    const promises = toCopyAssetFiles.map(async (path) => {
      const newPath = join(absoluteOutPath, relative(rootPath, path));
      const newParentDir = dirname(newPath);
      await sem.acquire();
      try {
        await Deno.mkdir(newParentDir, { recursive: true });
        await Deno.copyFile(path, newPath);
      } finally {
        sem.release();
      }
      console.error(`Copied ${path} to ${newPath}`);
    });
    await Promise.all(promises);
  }

  console.log(join(
    absoluteOutPath,
    relative(rootPath, absoluteAppPath).replace(/\.ts$/, ".js"),
  ));
} finally {
  try {
    await Deno.remove(vendorDir, { recursive: true });
  } catch {
    // Ignore
  }
}
