{ pkgs }:

pkgs.buildNpmPackage {
  pname = "node-red-packages";
  version = "1.0.0";

  src = ./.;

  npmDepsFetcherVersion = 2;

  npmDepsHash = pkgs.lib.fakeHash;

  dontNpmBuild = true;
}