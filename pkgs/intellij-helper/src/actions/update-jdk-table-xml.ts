import { parse, stringify } from "https://deno.land/x/xml@2.0.3/mod.ts";
import { join as joinPath } from "https://deno.land/std@0.113.0/path/mod.ts";
import { validate } from "https://raw.githubusercontent.com/shopstic/deno-utils/1.10.0/src/validation_utils.ts";
import {
  Type,
} from "https://raw.githubusercontent.com/shopstic/deno-utils/1.10.0/src/deps/typebox.ts";
import immerProduce from "https://cdn.skypack.dev/immer@9.0.7?dts";
import {
  createCliAction,
  ExitCode,
} from "https://raw.githubusercontent.com/shopstic/deno-utils/1.10.0/src/cli_utils.ts";

export const IntellijJdkTableSchema = Type.PartialObject({
  application: Type.PartialObject({
    component: Type.PartialObject({
      jdk: Type.Array(Type.PartialObject({
        name: Type.PartialObject({
          "@value": Type.String(),
        }),
      })),
    }),
  }),
});

export default createCliAction(
  Type.Object({
    name: Type.String({
      description: "The name of the JDK to add to the table",
      examples: ["my-app-jdk"],
    }),
    jdkPath: Type.String({
      description: "Absolute path to a JDK home to add to the table",
      examples: ["/path/to/jdk"],
    }),
    jdkTableXmlPath: Type.String({
      description: "Absolute path to Intellij's jdk.table.xml file",
      examples: [
        "/Users/foo/Library/Application Support/JetBrains/IntelliJIdea2021.2/options/jdk.table.xml",
      ],
    }),
    inPlace: Type.Optional(Type.Boolean({
      description: "Whether to patch the XML file in-place",
      examples: [false],
      default: false
    })),
  }),
  async (args) => {
    const { name, jdkPath, jdkTableXmlPath, inPlace } = args;

    const releaseFilePath = joinPath(jdkPath, "release");

    const releaseFile = await Deno.readTextFile(releaseFilePath);
    const releaseMap = Object.fromEntries(
      releaseFile.split("\n").filter((l) => l.length > 0).map((line) => {
        const match = line.match("^([^=]+)=(.+)");

        if (match) {
          const [_, key, value] = match;
          const unwrappedValue = (value.startsWith('"') && value.endsWith('"'))
            ? value.substring(1, value.length - 1)
            : value;
          return [key, unwrappedValue];
        } else {
          throw new Error(`Failed parsing line: ${line}`);
        }
      }),
    );

    if (!("IMPLEMENTOR" in releaseMap)) {
      throw new Error(
        `Missing IMPLEMENTOR in release file: ${releaseFilePath}`,
      );
    }

    if (!("JAVA_VERSION" in releaseMap)) {
      throw new Error(
        `Missing JAVA_VERSION in release file: ${releaseFilePath}`,
      );
    }

    if (!("MODULES" in releaseMap)) {
      throw new Error(`Missing MODULES in release file: ${releaseFilePath}`);
    }

    const implementor = releaseMap.IMPLEMENTOR;
    const javaVersion = releaseMap.JAVA_VERSION;
    const modules = releaseMap.MODULES.split(" ");

    const jdk = {
      "@version": 2,
      "name": {
        "@value": name,
        "#text": null,
      },
      "type": {
        "@value": "JavaSDK",
        "#text": null,
      },
      "version": {
        "@value": `${implementor} ${javaVersion}`,
        "#text": null,
      },
      "homePath": {
        "@value": jdkPath,
        "#text": null,
      },
      "roots": {
        "annotationsPath": {
          "root": {
            "@type": "composite",
            "root": {
              "@url":
                "jar://$APPLICATION_HOME_DIR$/plugins/java/lib/jdkAnnotations.jar!/",
              "@type": "simple",
              "#text": null,
            },
          },
        },
        "classPath": {
          "root": {
            "@type": "composite",
            "root": modules.map((mod) => ({
              "@url": `jrt://${jdkPath}!/${mod}`,
              "@type": "simple",
              "#text": null,
            })),
          },
        },
        "javadocPath": {
          "root": {
            "@type": "composite",
            "#text": null,
          },
        },
        "sourcePath": {
          "root": {
            "@type": "composite",
            "root": modules.map((mod) => ({
              "@url": `jrt://${jdkPath}/lib/src.zip!/${mod}`,
              "@type": "simple",
              "#text": null,
            })),
          },
        },
      },
      "additional": null,
    };

    const parsedTable = parse(await Deno.readTextFile(jdkTableXmlPath));

    const tableResult = validate(
      IntellijJdkTableSchema,
      parsedTable,
    );

    if (!tableResult.isSuccess) {
      throw new Error(
        `Failed validating Intellij JDK table from ${jdkTableXmlPath}. Errors:\n${
          tableResult.errorsToString({
            separator: "\n",
            dataVar: "  -",
          })
        }`,
      );
    }

    const table = tableResult.value;

    const updatedIntellijJdkTable = immerProduce(table, (draft) => {
      const component = draft.application.component;

      component.jdk = [
        ...component.jdk.filter((j) => j.name["@value"] !== name),
        jdk,
      ];
    });

    const out = stringify(updatedIntellijJdkTable)

    if (inPlace) {
      await Deno.writeTextFile(jdkTableXmlPath, out)
    }
    else {
      console.log(out);
    }

    return ExitCode.Zero;
  },
);
