import {
  transpile,
  type TranspileOptions,
} from "https://deno.land/x/emit@0.38.3/mod.ts";
import {
  dirname,
  fromFileUrl,
  join,
  relative,
  resolve,
  toFileUrl,
} from "jsr:@std/path@0.221.0";
import ts from "https://esm.sh/typescript@5.4.4";
import { assert } from "jsr:@std/assert@0.221.0";
import { inheritExec } from "jsr:@wok/utils@1.2.0/exec";
import { createCache } from "https://deno.land/x/deno_cache@0.7.1/mod.ts";
import { parseFromJson } from "https://deno.land/x/import_map@v0.19.1/mod.ts";

const [appPath, outPath] = Deno.args;

if (!appPath) {
  throw new Error("App path is required");
}

const absoluteAppPath = resolve(appPath);

if (!outPath) {
  throw new Error("Output path is required");
}
const absoluteOutPath = resolve(outPath);
const rootPath = Deno.cwd();

await inheritExec({
  cmd: ["deno", "vendor", absoluteAppPath],
});

const importMapUrl = toFileUrl(resolve("./vendor/import_map.json"));

type Load = NonNullable<TranspileOptions["load"]>;
type LoadParams = Parameters<Load>;

const cache = createCache({ allowRemote: false });

const result = await transpile(absoluteAppPath, {
  importMap: importMapUrl,
  allowRemote: false,
  async load(
    specifier: string,
    isDynamic?: boolean,
    cacheSetting?: LoadParams[2],
    checksum?: string,
  ) {
    if (specifier.startsWith("node:")) {
      return {
        kind: "external",
        specifier,
      };
    }
    return await cache.load(specifier, isDynamic, cacheSetting, checksum);
  },
});

const importMap = await parseFromJson(
  importMapUrl,
  await Deno.readTextFile(importMapUrl),
);

function rewriteModuleSpecifier(path: string, specifier: string) {
  if (
    !specifier.startsWith("./") && !specifier.startsWith("../") &&
    !specifier.startsWith("node:")
  ) {
    const parentPath = dirname(path);
    const resolved = importMap.resolve(specifier, toFileUrl(path));
    const resolvedRelative = relative(parentPath, fromFileUrl(resolved))
      .replace(/\.ts$/, ".js");

    if (!resolvedRelative.startsWith(".")) {
      return `./${resolvedRelative}`;
    }

    return resolvedRelative;
  }

  return specifier.replace(/\.ts$/, ".js");
}

function transformFile(filePath: string, sourceCode: string) {
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
}

const promises = Array.from(result).map(async ([key, content]) => {
  const path = fromFileUrl(key);
  const newPath = join(
    absoluteOutPath,
    relative(rootPath, path).replace(/\.ts$/, ".js"),
  );
  const newParentDir = dirname(newPath);
  await Deno.mkdir(newParentDir, { recursive: true });
  await Deno.writeTextFile(newPath, transformFile(path, content));
  console.log(`Wrote ${newPath}`);
});
await Promise.all(promises);
