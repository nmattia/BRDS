let
  # Use pinned packages
  _nixpkgs = import <nixpkgs> {};
  nixpkgs = _nixpkgs.fetchFromGitHub
    ({
        owner = "nmattia";
        repo = "nixpkgs";
        rev = "02359c639193103812f7356564326556cbb41ca4";
        sha256= "1rg0czkxqynycw23v0dmk0vd2v17d6v3yr06bg23wqwpm3b5z0nd";
    });

  # Create a package set with some overlays
  pkgs = import nixpkgs
    {
      overlays =
        [
          (self: super:
            {
              haskellPackages = super.haskellPackages.override
                {
                  overrides = haskellSelf: haskellSuper:
                    # shelly is broken
                    # (somewhat related issue:
                    #   https://github.com/NixOS/nixpkgs/issues/33113)
                    { shelly = pkgs.haskell.lib.dontCheck haskellSuper.shelly;
                    };
                };
            })
        ];

      # Make some packages available to IHaskell
      config =
        { ihaskell =
            { packages = ps:
                [
                  ps.ihaskell-inline-r
                  ps.lens
                  ps.lens-aeson
                  ps.vector
                  ps.wreq
                  ps.compact
                ];
            };
        };
    };
in pkgs.stdenv.mkDerivation
  {
    name = "my-jupyter";
    src = null;
    buildInputs =
      [ pkgs.ihaskell
        pkgs.R
      ];
  }
