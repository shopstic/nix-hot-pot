import { resolve, toFileUrl } from "@std/path";
import ts from "typescript";
import { assert } from "@std/assert/assert";
import { createCliAction, ExitCode } from "@wok/utils/cli";
import { parseImportMapFromJson } from "../lib/import_map.ts";
import { NonEmpStr } from "@wok/schema";
import { walk } from "@std/fs/walk";
import { AsyncQueue } from "@wok/utils/async-queue";

interface Replacement {
  start: number;
  end: number;
  newText: string;
}

function transformFile(
  { filePath, sourceCode, rewriteSpecifier }: {
    filePath: string;
    sourceCode: string;
    rewriteSpecifier: (path: string, specifier: string) => string;
  },
) {
  const sourceFile = ts.createSourceFile(
    filePath,
    sourceCode,
    ts.ScriptTarget.Latest,
    true,
  );

  // Store replacements with their positions
  const replacements: Replacement[] = [];

  const transformer: ts.TransformerFactory<ts.SourceFile> = (
    ctx: ts.TransformationContext,
  ) => {
    const { factory } = ctx;
    return (sourceFile: ts.SourceFile) => {
      function visit(node: ts.Node): ts.Node {
        if (ts.isImportDeclaration(node) || ts.isExportDeclaration(node)) {
          const moduleSpecifier = node.moduleSpecifier;
          if (moduleSpecifier && ts.isStringLiteral(moduleSpecifier)) {
            const newSpecifier = rewriteSpecifier(
              filePath,
              moduleSpecifier.text,
            );
            const newNode = ts.isImportDeclaration(node)
              ? factory.updateImportDeclaration(
                node,
                node.modifiers,
                node.importClause,
                factory.createStringLiteral(newSpecifier),
                node.attributes,
              )
              : factory.updateExportDeclaration(
                node,
                node.modifiers,
                node.isTypeOnly,
                node.exportClause,
                factory.createStringLiteral(newSpecifier),
                node.attributes,
              );

            // Capture the original module specifier's position and replacement
            const start = moduleSpecifier.getStart(sourceFile);
            const end = moduleSpecifier.getEnd();
            replacements.push({
              start,
              end,
              newText: `"${newSpecifier}"`, // Include quotes as in the original
            });

            return newNode;
          }
        }
        return ts.visitEachChild(node, visit, ctx);
      }

      const ret = ts.visitNode(sourceFile, visit);
      assert(ts.isSourceFile(ret));
      return ret;
    };
  };

  // Apply transformation to get the new AST
  const ret = ts.transform(sourceFile, [transformer]);
  assert(ret.transformed.length === 1);

  // Optimize replacement by building an array of segments
  if (replacements.length === 0) return sourceCode;

  // Sort replacements by start position (ascending) for sequential processing
  replacements.sort((a, b) => a.start - b.start);

  const segments: string[] = [];
  let lastPos = 0;

  for (const { start, end, newText } of replacements) {
    // Add the unchanged portion before this replacement
    if (lastPos < start) {
      segments.push(sourceCode.slice(lastPos, start));
    }
    // Add the new text
    segments.push(newText);
    lastPos = end;
  }

  // Add the remaining portion of the file
  if (lastPos < sourceCode.length) {
    segments.push(sourceCode.slice(lastPos));
  }

  // Join all segments once at the end
  return segments.join("");
}

export const unmapSpecifiersAction = createCliAction(
  {
    importMap: NonEmpStr({ description: "Path to the import map" }),
    srcDir: NonEmpStr({ description: "Path to the source directory" }),
  },
  async ({ importMap: importMapPath, srcDir }) => {
    const absoluteSrcPath = resolve(srcDir);
    const importMapUrl = toFileUrl(importMapPath);
    const importMap = await parseImportMapFromJson(
      importMapUrl,
      await Deno.readTextFile(importMapUrl),
      { expandImports: true },
    );
    const rewriteSpecifier = (path: string, specifier: string) => {
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

    for await (
      const filePath of AsyncQueue
        .from(walk(absoluteSrcPath))
        .filter((file) => file.path.endsWith(".ts"))
        .concurrentMap(32, async (file) => {
          const content = await Deno.readTextFile(file.path);
          const newContent = transformFile({
            filePath: file.path,
            sourceCode: content,
            rewriteSpecifier,
          });
          await Deno.writeTextFile(file.path, newContent);
          return file.path;
        })
    ) {
      console.error("transformed", filePath);
    }

    return ExitCode.Zero;
  },
);
