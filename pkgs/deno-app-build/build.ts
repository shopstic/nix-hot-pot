import { transpile, type TranspileOptions } from "./emit.ts";
import {
  dirname,
  fromFileUrl,
  join,
  relative,
  resolve,
  toFileUrl,
} from "@std/path";
import ts from "typescript";
import { assert } from "@std/assert/assert";
import { exists } from "@std/fs/exists";
import { inheritExec } from "@wok/utils/exec";
import { NonEmptyString, Type } from "@wok/typebox";
import { CliProgram, createCliAction, ExitCode } from "@wok/utils/cli";
import { Semaphore } from "@wok/utils/semaphore";
import { parseFromJson } from "../_deno-shared/import_map.ts";

function isRelativePath(path: string) {
  return path.startsWith("./") || path.startsWith("../");
}

type Load = NonNullable<TranspileOptions["load"]>;
type LoadParams = Parameters<Load>;

const buildAction = createCliAction(
  {
    allowNpmSpecifier: Type.Optional(Type.Boolean()),
    appPath: NonEmptyString(),
    outPath: NonEmptyString(),
  },
  async (args, signal) => {
    const { allowNpmSpecifier = false, appPath, outPath } = args;

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
        signal,
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
              specifier.startsWith("node:") || specifier.startsWith("data:") ||
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
          !specifier.startsWith("data:") &&
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

    return ExitCode.Zero;
  },
);

await new CliProgram()
  .addAction("build", buildAction)
  .run(Deno.args);
