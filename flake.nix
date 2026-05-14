{
  description = "A Typst project that uses Typst packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    typix = {
      url = "github:loqusion/typix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    # Example of downloading icons from a non-flake source
    # font-awesome = {
    #   url = "github:FortAwesome/Font-Awesome";
    #   flake = false;
    # };
  };

  outputs = inputs @ {
    nixpkgs,
    typix,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib;

      typixLib = typix.lib.${system};

      src = typixLib.cleanTypstSource ./.;
      commonArgs = {
        fontPaths = [
          # Add paths to fonts here
          # "${pkgs.roboto}/share/fonts/truetype"
          "${pkgs.garamond-libre}/share/fonts/opentype"
        ];

        virtualPaths = [
          # Add paths that must be locally accessible to typst here
          # {
          #   dest = "icons";
          #   src = "${inputs.font-awesome}/svgs/regular";
          # }
          {
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                (lib.fileset.fromSource src)
                ./cv
              ];
            };
          }
        ];
      };

      unstable_typstPackages = [
        {
          name = "imprecv";
          version = "1.0.1";
          hash = "sha256-gjsN2r416Xfg+xrp/5pgePjAVA9nCjB/lPU2UuYybJw=";
        }
      ];

      # Compile a Typst project, *without* copying the result
      # to the current directory
      build-drv = typixLib.buildTypstProject (commonArgs
        // {
          inherit src unstable_typstPackages;
          typstSource = "default.typ";
        });

      # Compile a Typst project, and then copy the result
      # to the current directory
      default-cv = typixLib.buildTypstProjectLocal (commonArgs
        // {
          inherit src unstable_typstPackages;
          typstSource = "default.typ";

        });

      # Watch a project and recompile on changes
      watch-script = typixLib.watchTypstProject (commonArgs
        // {
          typstSource = "*.typ";
        });
    in {
      checks = {
        inherit build-drv default-cv watch-script;
      };

      packages.default = build-drv;

      apps = rec {
        default = watch;
        build = flake-utils.lib.mkApp {
          drv = default-cv;
        };
        watch = flake-utils.lib.mkApp {
          drv = watch-script;
        };
      };

      devShells.default = typixLib.devShell {
        inherit (commonArgs) fontPaths virtualPaths;
        packages = [
          # WARNING: Don't run `typst-build` directly, instead use `nix run .#build`
          # See https://github.com/loqusion/typix/issues/2
          # default
          watch-script
          # More packages can be added here, like typstfmt
          # pkgs.typstfmt
          pkgs.yaml-language-server
        ];
      };
    });
}
