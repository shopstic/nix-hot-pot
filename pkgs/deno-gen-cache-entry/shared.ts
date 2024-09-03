import ts from "typescript";

export function extractImportExportSpecifiers(
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

  function visit(node: ts.Node): void {
    if (ts.isImportDeclaration(node) || ts.isExportDeclaration(node)) {
      if (node.moduleSpecifier && ts.isStringLiteral(node.moduleSpecifier)) {
        const specifier = node.moduleSpecifier.text;
        specifierSet.add(specifier);
      }
    } else {
      ts.forEachChild(node, visit);
    }
  }

  visit(sourceFile);

  return specifierSet;
}
