#!/usr/bin/env node
import openapiTs from "openapi-typescript";

const schemaFilePath = process.argv[2];
if (!schemaFilePath) {
  console.error("Schema file path must be provided as the first argument");
  process.exit(1);
}

const formatterFilePath = process.argv[3];
const formatter = await (async () => {
  if (formatterFilePath) {
    const formatterMod = await import(formatterFilePath);
    if (typeof formatterMod !== 'object' || typeof formatterMod.default !== 'function') {
      console.error(`Formatter module imported from ${formatterFilePath} does not have a default export that is a function`);
      process.exit(1);
    }
    return formatterMod.default;
  }
  return () => { };
})();

openapiTs(schemaFilePath, {
  formatter
}).then(ret => {
  console.log(ret)
}, error => {
  console.error(error);
  process.exit(1);
});