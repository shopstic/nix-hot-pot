import { resolve, toFileUrl } from "@std/path";
import ts from "typescript";
import { assert } from "@std/assert/assert";
import { createCliAction, ExitCode } from "@wok/utils/cli";
import { parseImportMapFromJson } from "$shared/import_map.ts";
import { NonEmpStr } from "@wok/schema";
import { walk } from "@std/fs/walk";
import { AsyncQueue } from "@wok/utils/async-queue";

export const unmapSpecifiersAction = createCliAction(
  {
    importMapPath: NonEmpStr(),
    srcPath: NonEmpStr(),
  },
  async ({ importMapPath, srcPath }) => {
    const absoluteSrcPath = resolve(srcPath);
    const importMapUrl = toFileUrl(importMapPath);
    const importMap = await parseImportMapFromJson(
      importMapUrl,
      await Deno.readTextFile(importMapUrl),
      { expandImports: true },
    );
    const rewriteModuleSpecifier = (path: string, specifier: string) => {
      if (
        specifier.startsWith("./") ||
        specifier.startsWith("../") ||
        specifier.startsWith("/") ||
        specifier.startsWith("node:") ||
        specifier.startsWith("data:") ||
        specifier.startsWith("http:") ||
        specifier.startsWith("https:")
      ) {
        return specifier;
      }

      return importMap.resolve(specifier, toFileUrl(path));
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
                node.moduleSpecifier &&
                ts.isStringLiteral(node.moduleSpecifier)
              ) {
                return factory.updateImportDeclaration(
                  node,
                  node.modifiers,
                  node.importClause,
                  factory.createStringLiteral(
                    rewriteModuleSpecifier(
                      filePath,
                      node.moduleSpecifier.text,
                    ),
                  ),
                  node.attributes,
                );
              }

              return node;
            }

            if (ts.isExportDeclaration(node)) {
              if (
                node.moduleSpecifier &&
                ts.isStringLiteral(node.moduleSpecifier)
              ) {
                return factory.updateExportDeclaration(
                  node,
                  node.modifiers,
                  node.isTypeOnly,
                  node.exportClause,
                  factory.createStringLiteral(
                    rewriteModuleSpecifier(
                      filePath,
                      node.moduleSpecifier.text,
                    ),
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

    for await (
      const filePath of AsyncQueue
        .from(walk(absoluteSrcPath))
        .filter((file) => file.path.endsWith(".ts"))
        .concurrentMap(32, async (file) => {
          const content = await Deno.readTextFile(file.path);
          const newContent = transformFile(file.path, content);
          await Deno.writeTextFile(file.path, newContent);
          return file.path;
        })
    ) {
      console.error("transformed", filePath);
    }

    return ExitCode.Zero;
  },
);
