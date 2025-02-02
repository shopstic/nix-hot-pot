import { Tagged } from "type-fest";

export type PackageType = "npm" | "jsr";
export type PackageName = Tagged<string, "PackageName">;
export type PackagePath = Tagged<string, "PackagePath">;

export interface PackageSpecifier {
  type: PackageType;
  name: PackageName;
  version?: string;
  path?: PackagePath;
}

// Parse the remainder of the spec string for name, version, and path.
const SPECIFIER_REGEX =
  /^(?<name>(?:@[a-z0-9-~][a-z0-9-._~]*\/)?[a-z0-9-~][a-z0-9-._~]*)(?:@(?<version>[^/]+))?(?:\/(?<path>.+))?$/;

export function parsePackageSpecifier(
  spec: string,
  providedType?: PackageType,
): PackageSpecifier | undefined {
  let type: PackageType;

  // If a PackageType is provided, assume that the spec does not include a scheme prefix.
  if (providedType) {
    type = providedType;
  } else {
    // Otherwise, extract the scheme explicitly.
    if (spec.startsWith("npm:")) {
      type = "npm";
      spec = spec.slice(4 + (spec[4] === "/" ? 1 : 0));
    } else if (spec.startsWith("jsr:")) {
      type = "jsr";
      spec = spec.slice(4 + (spec[4] === "/" ? 1 : 0));
    } else {
      return undefined;
    }
  }

  const match = spec.match(SPECIFIER_REGEX);
  if (!match || !match.groups) {
    return undefined;
  }

  const { name, version, path } = match.groups;

  return {
    type,
    name: name as PackageName,
    version: version ? version : undefined,
    path: path ? (path as PackagePath) : undefined,
  };
}

export function stringifyPackageSpecifier(spec: PackageSpecifier): string {
  const { type, name, version, path } = spec;
  return `${type}:${name}${version ? `@${version}` : ""}${
    path ? `/${path}` : ""
  }`;
}
