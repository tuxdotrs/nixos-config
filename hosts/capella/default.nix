{
  modulesPath,
  inputs,
  username,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.default
    (import ./disko.nix {device = "/dev/sda";})

    ../common
    ../../modules/nixos/virtualisation/docker.nix
    ../../modules/nixos/containers/cs2.nix
  ];

  sops.secrets = {
    "cs2_secrets/SRCDS_TOKEN" = {
      sopsFile = ./secrets.yaml;
    };

    "cs2_secrets/CS2_RCONPW" = {
      sopsFile = ./secrets.yaml;
    };

    "cs2_secrets/CS2_PW" = {
      sopsFile = ./secrets.yaml;
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    hostName = "capella";
    firewall.enable = false;
  };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  environment.persistence."/persist" = {
    enable = false;
  };

  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  system.stateVersion = "24.11";
}
