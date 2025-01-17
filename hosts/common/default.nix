{
  pkgs,
  username,
  outputs,
  config,
  lib,
  inputs,
  email,
  ...
}: let
  # Sops needs acess to the keys before the persist dirs are even mounted; so
  # just persisting the keys won't work, we must point at /persist
  hasOptinPersistence = config.environment.persistence."/persist".enable;
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager

    ../../modules/nixos/fail2ban.nix
    ../../modules/nixos/sops.nix
  ];

  sops.secrets.tux-password = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
      outputs.overlays.nur
      outputs.overlays.nix-vscode-extensions
    ];

    config = {
      allowUnfree = true;
      joypixels.acceptLicense = true;
    };
  };

  nix = {
    package = pkgs.lix;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = ["${username}"];
      warn-dirty = false;
      substituters = [
        "https://cache.nixos.org?priority=10"
        "https://anyrun.cachix.org"
        "https://fufexan.cachix.org"
        "https://helix.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://yazi.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      ];
    };
  };

  time.timeZone = "Asia/Kolkata";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_IN";
      LC_IDENTIFICATION = "en_IN";
      LC_MEASUREMENT = "en_IN";
      LC_MONETARY = "en_IN";
      LC_NAME = "en_IN";
      LC_NUMERIC = "en_IN";
      LC_PAPER = "en_IN";
      LC_TELEPHONE = "en_IN";
      LC_TIME = "en_IN";
    };
  };

  security.sudo.wheelNeedsPassword = false;

  programs = {
    zsh.enable = true;
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 5d --keep 5";
      flake = "/home/${username}/Projects/nixos-config";
    };
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };

      hostKeys = [
        {
          path = "${lib.optionalString hasOptinPersistence "/persist"}/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    users.${username} = {
      hashedPasswordFile = config.sops.secrets.tux-password.path;
      isNormalUser = true;
      extraGroups = ["networkmanager" "wheel" "storage"];
      openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+OzPUe2ECPC929DqpkM39tl/vdNAXfsRnmrGfR+X3D ${email}''
      ];
    };
  };

  home-manager = {
    backupFileExtension = "hm-backup";
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs outputs username email;};
    users.${username} = {
      imports = [
        ./home.nix
      ];
    };
  };
}
