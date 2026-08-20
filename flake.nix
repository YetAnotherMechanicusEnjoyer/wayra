{
  description = "wayra - A lightweight, high-performance standalone web server and directory explorer.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          zigDeps = pkgs.callPackage ./deps.nix {};
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "wayra";
            version = "0.1.1";

            src = ./.;

            nativeBuildInputs = [ pkgs.zig ];

            preBuild = ''
              export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
              export ZIG_LOCAL_CACHE_DIR=$TMPDIR/zig-cache

              mkdir -p $ZIG_GLOBAL_CACHE_DIR/p
              cp -r --no-preserve=mode,ownership ${zigDeps}/* $ZIG_GLOBAL_CACHE_DIR/p/ 2>/dev/null || true
            '';

            buildPhase = ''
              zig build --system ${zigDeps} -Doptimize=ReleaseFast --prefix $out
            '';

            installPhase = ''
              true
            '';
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [ zig zls ];
          };
        });
    };
}
