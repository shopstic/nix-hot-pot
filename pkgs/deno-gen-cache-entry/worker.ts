import { runAsQueueWorker } from "@wok/utils/queue-worker/worker";
import { isSelfWorker } from "@wok/utils/queue-worker/shared";
import { getDefaultLogger } from "@wok/utils/logger";
import { gray } from "@std/fmt/colors";
import { format as formatDuration } from "@std/fmt/duration";
import { extractImportExportSpecifiers } from "./shared.ts";

if (!isSelfWorker(self)) {
  throw new Error("Expected to be run as a worker.");
}

const workerName = self.name ?? "worker";
const logger = getDefaultLogger().prefixed(gray(workerName));

await runAsQueueWorker<string, string[]>(async (filePath) => {
  const startTime = performance.now();
  const sourceCode = await Deno.readTextFile(filePath);
  const specifierSet = extractImportExportSpecifiers(filePath, sourceCode);
  logger.info?.(
    filePath,
    specifierSet.size,
    gray(formatDuration(performance.now() - startTime, { ignoreZero: true })),
  );
  return Array.from(specifierSet);
}, {
  logger,
});
