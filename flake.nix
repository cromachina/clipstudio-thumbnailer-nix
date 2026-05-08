{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      script = "clipstudio-thumbnailer.sh";
      deps = with pkgs; [ sqlite coreutils gnugrep bash ];
      clipstudio-thumbnailer-lib = pkgs.stdenv.mkDerivation {
        name = "clipstudio-thumbnailer-lib";
        src = pkgs.fetchFromGitHub {
          owner = "ludospex";
          repo = "clipstudio-thumbnailer";
          rev = "3bb5cfe5a426eb2a725abf32b44e75885a306240";
          hash = "sha256-u3lahWBz8f11abnKYaqwjgJZ9zte9tTV7rPVpoeaBJw=";
        };
        nativeBuildInputs = [ pkgs.makeWrapper ];
        phases = [ "unpackPhase" "installPhase" ];
        installPhase = ''
          mkdir -p $out/bin
          cp ${script} $out/bin/.${script}-bash-wrapped.sh
          echo "#! /usr/bin/env bash
          bash $out/bin/.${script}-bash-wrapped.sh \$@" > $out/bin/${script}
          chmod a+x $out/bin/${script}
          wrapProgram $out/bin/${script} --prefix PATH : ${pkgs.lib.makeBinPath deps}

          mkdir -p $out/share/mime/packages
          cp $src/clipstudio.xml $out/share/mime/packages/
        '';
      };
      thumbnailer = pkgs.writeTextFile {
        name = "clipstudio-thumbnailer";
        destination = "/share/thumbnailers/clipstudio.thumbnailer";
        text = ''
          [Thumbnailer Entry]
          Exec=${clipstudio-thumbnailer-lib}/bin/${script} %i %o
          MimeType=application/x-clip;image/x-clip;application/octet-stream;
        '';
      };
      in {
        packages.default = pkgs.symlinkJoin {
          name = "clipstudio-thumbnailer";
          paths = [ clipstudio-thumbnailer-lib thumbnailer ];
        };
      }
  );
}