import { runAsQueueWorker } from "@wok/utils/queue-worker/worker";
import { isSelfWorker } from "@wok/utils/queue-worker/shared";
import ts from "typescript";
import { assert } from "@std/assert";
import { getDefaultLogger } from "@wok/utils/logger";
import { gray } from "@std/fmt/colors";
import { format as formatDuration } from "@std/fmt/duration";

if (!isSelfWorker(self)) {
  throw new Error("Expected to be run as a worker.");
}

function extractRemoteDependencies(
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

const workerName = self.name ?? "worker";
const logger = getDefaultLogger().prefixed(gray(workerName));

await runAsQueueWorker<string, string[]>(async (filePath) => {
  const startTime = performance.now();
  const sourceCode = await Deno.readTextFile(filePath);
  const specifierSet = extractRemoteDependencies(filePath, sourceCode);
  logger.info?.(
    filePath,
    specifierSet.size,
    gray(formatDuration(performance.now() - startTime, { ignoreZero: true })),
  );
  return Array.from(specifierSet);
}, {
  logger,
});
