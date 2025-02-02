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

const PACKAGE_SPECIFIER_REGEX =
  /^(?<scheme>npm:|jsr:)\/?(?<name>(?:@[a-z0-9-~][a-z0-9-._~]*\/)?[a-z0-9-~][a-z0-9-._~]*)(?:@(?<version>[^/]+))?(?:\/(?<path>.+))?$/;

export function parsePackageSpecifier(
  spec: string,
): PackageSpecifier | undefined {
  const match = spec.match(PACKAGE_SPECIFIER_REGEX);
  if (!match || !match.groups) {
    return undefined;
  }

  const { scheme, name, version, path } = match.groups;
  const type = scheme.slice(0, -1) as PackageType;

  return {
    type,
    name: name as PackageName,
    version: version ?? undefined,
    path: path as PackagePath ?? undefined,
  };
}

export function stringifyPackageSpecifier(spec: PackageSpecifier): string {
  const { type, name, version, path } = spec;
  return `${type}:${name}${version ? `@${version}` : ""}${
    path ? `/${path}` : ""
  }`;
}
