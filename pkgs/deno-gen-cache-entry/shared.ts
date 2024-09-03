import {
  createSourceFile,
  forEachChild,
  isExportDeclaration,
  isImportDeclaration,
  isStringLiteral,
  type Node,
  ScriptTarget,
} from "typescript";

export function extractImportExportSpecifiers(
  filePath: string,
  sourceCode: string,
): Set<string> {
  const specifierSet = new Set<string>();
  const sourceFile = createSourceFile(
    filePath,
    sourceCode,
    ScriptTarget.Latest,
    true,
  );

  function visit(node: Node): void {
    if (isImportDeclaration(node) || isExportDeclaration(node)) {
      if (node.moduleSpecifier && isStringLiteral(node.moduleSpecifier)) {
        const specifier = node.moduleSpecifier.text;
        specifierSet.add(specifier);
      }
    } else {
      forEachChild(node, visit);
    }
  }

  visit(sourceFile);

  return specifierSet;
}
