import ts from "typescript";
import { assert } from "@std/assert";

export function extractRemoteDependencies(
  filePath: string,
  sourceCode: string,
): Set<string> {
  const specifierSet = new Set<string>();
  const sourceFile = ts.createSourceFile(
    filePath,
    sourceCode,
    ts.ScriptTarget.Latest,
    true,
  );

  const transformer: ts.TransformerFactory<ts.SourceFile> = (
    ctx: ts.TransformationContext,
  ) => {
    return (sourceFile: ts.SourceFile) => {
      function visit(node: ts.Node): ts.Node {
        if (ts.isImportDeclaration(node)) {
          if (
            node.moduleSpecifier &&
            ts.isStringLiteral(node.moduleSpecifier)
          ) {
            const specifier = node.moduleSpecifier.text;
            specifierSet.add(specifier);
          }

          return node;
        }

        if (ts.isExportDeclaration(node)) {
          if (
            node.moduleSpecifier &&
            ts.isStringLiteral(node.moduleSpecifier)
          ) {
            const specifier = node.moduleSpecifier.text;
            specifierSet.add(specifier);
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

  ts.transform(sourceFile, [transformer]);
  return specifierSet;
}
