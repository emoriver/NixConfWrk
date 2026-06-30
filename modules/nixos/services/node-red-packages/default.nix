{ pkgs }:

pkgs.buildNpmPackage {
  pname = "node-red-packages";
  version = "1.0.0";

  src = ./.;

  npmDepsFetcherVersion = 2;

  npmDepsHash = pkgs.lib.fakeHash;
  #npmDepsHash = "sha256-0q89/z2e8pKcQhsq+L3rn6eJoVF2j1K64tuHh/auohw=";

  dontNpmBuild = true;
}