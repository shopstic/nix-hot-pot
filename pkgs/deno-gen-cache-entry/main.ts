import { exists, walk } from "@std/fs";
import { CliProgram, createCliAction, ExitCode } from "@wok/utils/cli";
import { AsyncQueue } from "@wok/utils/async-queue";
import { NonEmptyString, NonNegInt, PosInt, Type } from "@wok/typebox";
import { QueueWorkerTask } from "@wok/utils/queue-worker/shared";
import { runQueueWorker } from "@wok/utils/queue-worker/main";
import { assert } from "@std/assert/assert";
import { getDefaultLogger } from "@wok/utils/logger";
import { gray } from "@std/fmt/colors";
import { resolve } from "@std/path/resolve";
import { toFileUrl } from "@std/path/to-file-url";
import { parseFromJson } from "../_deno-shared/import_map.ts";
import { join } from "@std/path/join";
import { extractImportExportSpecifiers } from "./shared.ts";
import { format as formatDuration } from "@std/fmt/duration";

const logger = getDefaultLogger().prefixed(gray("main"));

type Task = QueueWorkerTask<string, string[]>;

const run = createCliAction(
  {
    concurrency: Type.Optional(PosInt({ default: 32 })),
    workerCount: Type.Optional(
      NonNegInt({
        default: 0,
        description:
          "Number of worker threads. Set to 0 to run in the main thread only",
      }),
    ),
    srcPath: NonEmptyString(),
  },
  async (
    { concurrency = 32, workerCount = 0, srcPath },
    signal,
  ) => {
    const resolvedSrcPath = resolve(srcPath);
    const denoConfigPath = join(resolvedSrcPath, "deno.json");

    if (!(await exists(denoConfigPath))) {
      logger.error?.("deno.json not found at", denoConfigPath);
      return ExitCode.One;
    }

    logger.info?.("Generating cache entry for", resolvedSrcPath);
    logger.info?.(
      "Using concurrency:",
      concurrency,
      "workerCount:",
      workerCount,
    );

    const importMap = await parseFromJson(
      toFileUrl(denoConfigPath),
      await Deno.readTextFile(denoConfigPath),
      { expandImports: true },
    );

    const allSpecifiers = new Set<string>();
    const queue = new AsyncQueue<Task>(1);
    const workerPromises: Promise<void>[] = workerCount > 0
      ? Array
        .from({ length: workerCount })
        .map((_, i) =>
          runQueueWorker(queue, {
            url: new URL("./worker.ts", import.meta.url),
            name: `worker-${i}`,
            concurrency: 1,
            signal,
          })
        )
      : [
        (async () => {
          for await (
            const _ of queue.concurrentMap(concurrency, async (task) => {
              const { input: filePath, promise: resolver } = task;
              const startTime = performance.now();

              try {
                const specifierSet = extractImportExportSpecifiers(
                  filePath,
                  await Deno.readTextFile(filePath),
                );
                resolver.resolve(Array.from(specifierSet));
                logger.info?.(
                  filePath,
                  specifierSet.size,
                  gray(
                    formatDuration(performance.now() - startTime, {
                      ignoreZero: true,
                    }),
                  ),
                );
              } catch (error) {
                resolver.reject(error);
              }
            })
          ) {
            if (signal.aborted) {
              return;
            }
          }
        })(),
      ];

    const mainPromise = (async () => {
      try {
        for await (
          const { fileUrl, specifiers } of AsyncQueue
            .from(walk(resolvedSrcPath))
            .filter((entry) => entry.isFile && entry.name.endsWith(".ts"))
            .concurrentMap(concurrency, async (entry) => {
              const deferrred = Promise.withResolvers<string[]>();
              const task = {
                input: entry.path,
                promise: deferrred,
                signal,
              } satisfies Task;

              assert(await queue.enqueue(task));
              return {
                fileUrl: toFileUrl(entry.path),
                specifiers: await deferrred.promise,
              };
            })
        ) {
          for (const specifier of specifiers) {
            const resolved = importMap.resolve(specifier, fileUrl);
            if (
              resolved.startsWith("file://") || resolved.startsWith("node:")
            ) {
              continue;
            }
            allSpecifiers.add(resolved);
          }
        }
      } finally {
        queue.complete();
      }
    })();

    await Promise.all([mainPromise, ...workerPromises]);

    const sorted = Array.from(allSpecifiers).sort();

    for (const specifier of sorted) {
      console.log(`import ${JSON.stringify(specifier)};`);
    }
    return ExitCode.Zero;
  },
);

await new CliProgram()
  .addAction("gen", run)
  .run(Deno.args);
