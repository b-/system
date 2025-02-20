{
  description = "nix system configurations";

  nixConfig = rec {
    max-jobs = "auto";

    substituters = [
      "https://cache.garnix.io"
      "https://cache.nixos.org"
      "https://bri.cachix.org"
      "https://perchnet.cachix.org"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    trusted-substituters = substituters;

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "perchnet.cachix.org-1:0mwmOwJFqL+r4HKl68GZ90ATTFsi3/L4ejSUIWaYYmc="
      "bri.cachix.org-1:/dk2nWYOEZl/BnC8h5CTKgao5HeWjCIgY1Tuj29Bq4s="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
    allowed-uris = [
      "github:hercules-ci/" # flake-parts
      "github:serokell/" # deploy-rs
      "github:cachix/" # cachix & devenv
      "github:nix-community/"
      "github:nixos/"
      "github:Mic92/" # nix-index-database
      "github:numtide/" # nixos-anywhere
      "github:lnl7/" # nix-darwin
      "github:zhaofengli/" # attic
      "github:ipetkov/crane/"

      # me
      "github:b-/"
      "github:briorg/"
      "github:perchnet/"

      "github:"
      "git+https://github.com/"
      "git+ssh://github.com/"
      "https://github.com/"
    ];
    trusted-users = [
      "root"
      "@admin"
      "@wheel"
    ];
  };

  inputs = rec {

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    ########################################
    # nixpkgs forks and branches
    nixos-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    my-nixos-unstable.url = "github:b-/nixpkgs/bri-nixos-unstable";
    #nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    #fh-nixpkgs-unstable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";

    # patch that fixes gocd-agent module
    gocd-agent-nixpkgs.url = "github:sgonzalezoyuela/nixpkgs/a9eba62d9e62cee71e69104a600023719e44eacc";

    # set primary nixpkgs and stable from above
    stable = nixos-stable;
    nixpkgs = nixos-unstable;

    ########################################
    # darwins
    upstream-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my-darwin = {
      url = "github:b-/nix-darwin/patch-1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = my-darwin;

    ########################################
    # home-managers
    upstream-home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my-home-manager-fork = {
      url = "github:b-/home-manager/zsh-aliases";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = upstream-home-manager;

    ########################################
    # hardware and vm support
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      # doesn't actually use nixpkgs
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/make-disk-image";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixos-anywhere = {
    #   url = "github:numtide/nixos-anywhere";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ########################################
    # shell stuff
    devenv = {
      url = "github:cachix/devenv/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ########################################
    # additional inputs
    attic = {
      url = "github:zhaofengli/attic";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "stable";
      };
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # flakehub cli
    fh = {
      url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    tsnsrv = {
      url = "github:boinkor-net/tsnsrv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      attic,
      darwin,
      deploy-rs,
      devenv,
      disko,
      flake-utils,
      home-manager,
      nixos-generators,
      self,
      ...
    }@inputs:
    let
      inherit (flake-utils.lib) eachSystemMap;

      isDarwin = system: (builtins.elem system inputs.nixpkgs.lib.platforms.darwin);
      homePrefix = system: if isDarwin system then "/Users" else "/home";
      defaultSystems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      # generate a base darwin configuration with the
      # specified hostname, overlays, and any extraModules applied
      mkDarwinConfig =
        {
          system ? "aarch64-darwin",
          nixpkgs ? inputs.nixpkgs,
          baseModules ? [
            home-manager.darwinModules.home-manager
            ./modules/darwin
          ],
          extraModules ? [ ],
        }:
        inputs.darwin.lib.darwinSystem {
          inherit system;
          modules = baseModules ++ extraModules;
          specialArgs = {
            inherit self inputs nixpkgs;
          };
        };

      # generate a base nixos configuration with the
      # specified overlays, hardware modules, and any extraModules applied
      mkNixosConfig =
        {
          system ? "x86_64-linux",
          nixpkgs ? inputs.nixos-unstable,
          hardwareModules,
          baseModules ? [
            home-manager.nixosModules.home-manager
            ./modules/nixos
            nixos-generators.nixosModules.all-formats
          ],
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ hardwareModules ++ extraModules;
          specialArgs = {
            inherit self inputs nixpkgs;
          };
        };

      # generate a home-manager configuration usable on any unix system
      # with overlays and any extraModules applied
      mkHomeConfig =
        {
          username,
          system ? "x86_64-linux",
          nixpkgs ? inputs.nixpkgs,
          baseModules ? [
            ./modules/home-manager
            {
              home = {
                inherit username;
                homeDirectory = "${homePrefix system}/${username}";
                sessionVariables = {
                  NIX_PATH = "nixpkgs=${nixpkgs}:stable=${inputs.stable}\${NIX_PATH:+:}$NIX_PATH";
                };
              };
            }
          ],
          extraModules ? [ ],
        }:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            overlays = builtins.attrValues self.overlays;
          };
          extraSpecialArgs = {
            inherit self inputs nixpkgs;
          };
          modules = baseModules ++ extraModules;
        };

      mkChecks =
        {
          arch,
          os,
          username ? "bri",
        }:
        {
          "${arch}-${os}" = {
            "${username}_${os}" =
              (if os == "darwin" then self.darwinConfigurations else self.nixosConfigurations)
              ."${username}@${arch}-${os}".config.system.build.toplevel;
            "${username}_home" = self.homeConfigurations."${username}@${arch}-${os}".activationPackage;
            devShell = self.devShells."${arch}-${os}".default;
          };
        };
    in
    {
      deploy.nodes.chromebook.profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."bri@x86_64-linux";
      };
      nixosModules.customFormats =
        { ... }:
        {
          formatConfigs.azure =
            { ... }:
            {
              fileExtension = ".vhd";
            };

          formatConfigs.docker =
            { lib, ... }:
            {
              services.resolved.enable = false;
              services.qemuGuest.enable = lib.mkForce false;
            };

          formatConfigs.oracle =
            { modulesPath, ... }:
            {
              imports = [ "${toString modulesPath}/virtualisation/oci-image.nix" ];

              formatAttr = "OCIImage";
              fileExtension = ".qcow2";
            };

          formatConfigs.proxmox =
            { ... }:
            {
              boot.kernelParams = [ "console=ttyS0" ];
              proxmox = {
                qemuConf = {
                  agent = true;
                  boot = "virtio0";
                  bios = "ovmf";
                  net0 = "virtio=00:00:00:00:00:00,bridge=BackV30";
                };
                qemuExtraConf = {
                  cpu = "host";
                };
              };
            };
          formatConfigs.proxmox-lxc =
            { lib, ... }:
            {
              boot.loader.systemd-boot.enable = lib.mkForce false;
            };
        };

      checks =
        { }
        // (mkChecks {
          arch = "aarch64";
          os = "darwin";
        })
        // (mkChecks {
          arch = "x86_64";
          os = "darwin";
        })
        // (mkChecks {
          arch = "aarch64";
          os = "linux";
        })
        // (mkChecks {
          arch = "x86_64";
          os = "linux";
        });

      darwinConfigurations = {
        "bri@aarch64-darwin" = mkDarwinConfig {
          system = "aarch64-darwin";
          extraModules = [
            ./profiles/personal.nix
            ./modules/darwin/apps.nix
          ];
        };
        "bri@x86_64-darwin" = mkDarwinConfig {
          system = "x86_64-darwin";
          extraModules = [
            ./profiles/personal.nix
            ./modules/darwin/apps.nix
          ];
        };
        #  "lejeukc1@aarch64-darwin" = mkDarwinConfig {
        #    system = "aarch64-darwin";
        #    extraModules = [./profiles/work.nix];
        #  };
        #  "lejeukc1@x86_64-darwin" = mkDarwinConfig {
        #    system = "aarch64-darwin";
        #    extraModules = [./profiles/work.nix];
        #  };
      };

      diskoConfigurations.test = import ./disk-config.nix;
      nixosConfigurations = {
        "bri@x86_64-linux" = mkNixosConfig {
          # imports = [
          # ];
          system = "x86_64-linux";
          hardwareModules = [
            ./modules/hardware/hardware.nix
            self.nixosModules.customFormats
            # inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t460s
          ];
          extraModules = [
            #./disk-config.nix
            ./modules/nixos/keybase.nix
            ./modules/nixos/desktop.nix
            #./modules/nixos/gnome.nix
            ./modules/nixos/plasma6.nix
            ./modules/nixos/hyprland.nix
            ./modules/nixos/tailscale.nix
            ./profiles/personal.nix
            attic.nixosModules.atticd
            disko.nixosModules.disko
          ];
        };
        "server@x86_64-linux" = mkNixosConfig {
          system = "x86_64-linux";
          hardwareModules = [
            ./modules/hardware/hardware.nix
            self.nixosModules.customFormats
          ];
          extraModules = [
            # ./modules/nixos/desktop.nix
            # ./modules/nixos/gnome.nix
            #./disk-config.nix
            ./modules/nixos/attic.nix
            ./modules/nixos/server.nix
            ./modules/nixos/tailscale.nix
            ./profiles/personal.nix
            attic.nixosModules.atticd
            disko.nixosModules.disko
          ];
        };
        "bri@aarch64-linux" = mkNixosConfig {
          system = "aarch64-linux";
          hardwareModules = [
            inputs.nixos-hardware.nixosModules.pine64-pinebook-pro
            ./modules/hardware/pinebook-pro.nix
          ];
          extraModules = [
            disko.nixosModules.disko
            #./disk-config.nix
            ./modules/nixos/tailscale.nix
            ./profiles/personal.nix
          ];
        };
      };

      homeConfigurations = {
        "bri@x86_64-linux" = mkHomeConfig {
          username = "bri";
          system = "x86_64-linux";
          extraModules = [ ./profiles/home-manager/personal.nix ];
        };
        "bri@aarch64-linux" = mkHomeConfig {
          username = "bri";
          system = "aarch64-linux";
          extraModules = [ ./profiles/home-manager/personal.nix ];
        };
        "bri@x86_64-darwin" = mkHomeConfig {
          username = "bri";
          system = "x86_64-darwin";
          extraModules = [ ./profiles/home-manager/personal.nix ];
        };
        "bri@aarch64-darwin" = mkHomeConfig {
          username = "bri";
          system = "aarch64-darwin";
          extraModules = [ ./profiles/home-manager/personal.nix ];
        };
        # "lejeukc1@x86_64-linux" = mkHomeConfig {
        #   username = "lejeukc1";
        #   system = "x86_64-linux";
        #   extraModules = [./profiles/home-manager/work.nix];
        # };
      };

      devShells = eachSystemMap defaultSystems (
        system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = builtins.attrValues self.overlays;
          };
        in
        {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [ (import ./devenv.nix) ];
          };
        }
      );

      packages = eachSystemMap defaultSystems (
        system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = builtins.attrValues self.overlays;
          };
        in
        rec {
          pyEnv = pkgs.python3.withPackages (
            ps: [
              ps.black
              ps.typer
              ps.colorama
              ps.shellingham
            ]
          );
          sysdo = pkgs.writeScriptBin "sysdo" ''
            #! ${pyEnv}/bin/python3
            ${builtins.readFile ./bin/do.py}
          '';
          cb = pkgs.writeShellScriptBin "cb" ''
                        #! ${pkgs.lib.getExe pkgs.bash}
                        # universal clipboard, stephen@niedzielski.com

            shopt - s expand_aliases


                        # ------------------------------------------------------------------------------
                        # os utils

                        case "$OSTYPE$(uname)" in
                          [lL]inux*) TUX_OS=1 ;;
                         [dD]arwin*) MAC_OS=1 ;;
                          [cC]ygwin) WIN_OS=1 ;;
                                  *) echo "unknown os=\"$OSTYPE$(uname)\"" >&2 ;;
                        esac

                        is_tux() { [ ''${TUX_OS-0} -ne 0 ]; }
                        is_mac() { [ ''${MAC_OS-0} -ne 0 ]; }
                        is_win() { [ ''${WIN_OS-0} -ne 0 ]; }

                        # ------------------------------------------------------------------------------
                        # copy and paste

                        if is_mac; then
                          alias cbcopy=pbcopy
                          alias cbpaste=pbpaste
                        elif is_win; then
                          alias cbcopy=putclip
                          alias cbpaste=getclip
                        else
                          alias cbcopy='${pkgs.xclip} -sel c'
                          alias cbpaste='${pkgs.xclip} -sel c -o'
                        fi

                        # ------------------------------------------------------------------------------
                        cb() {
                          if [ ! -t 0 ] && [ $# -eq 0 ]; then
                            # no stdin and no call for --help, blow away the current clipboard and copy
                            cbcopy
                          else
                            cbpaste ''${@:+"$@"}
                          fi
                        }

                        # ------------------------------------------------------------------------------
                        if ! return 2>/dev/null; then
                          cb ''${@:+"$@"}
                        fi
          '';
        }
      );

      apps = eachSystemMap defaultSystems (
        system: rec {
          sysdo = {
            type = "app";
            program = "${self.packages.${system}.sysdo}/bin/sysdo";
          };
          cb = {
            type = "app";
            program = "${self.packages.${system}.cb}/bin/cb";
          };
          default = sysdo;
        }
      );

      overlays = {
        channels = final: prev: {
          # expose other channels via overlays
          stable = import inputs.stable { system = prev.system; };
        };
        extraPackages = final: prev: {
          sysdo = self.packages.${prev.system}.sysdo;
          pyEnv = self.packages.${prev.system}.pyEnv;
          cb = self.packages.${prev.system}.cb;
          devenv = self.packages.${prev.system}.devenv;
        };
      };
      hydraJobs = {
        #serverRawEfi = self.nixosConfigurations."server@x86_64-linux".config.formats.raw-efi;
        serverProxmox = self.nixosConfigurations."server@x86_64-linux".config.formats.proxmox;
        serverProxmoxLxc = self.nixosConfigurations."server@x86_64-linux".config.formats.proxmox-lxc;
        #briProxmox = self.nixosConfigurations."bri@x86_64-linux".config.formats.proxmox;
        briRawEfi = self.nixosConfigurations."bri@x86_64-linux".config.formats.raw-efi;
      };
    };
}
