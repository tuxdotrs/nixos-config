{
  pkgs,
  inputs,
  username,
  config,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    ../common
    ../../modules/nixos/virtualisation/docker.nix
  ];

  nixpkgs = {
    config.cudaSupport = true;
    hostPlatform = "x86_64-linux";
  };

  wsl = {
    enable = true;
    defaultUser = "${username}";
    nativeSystemd = true;
    useWindowsDriver = true;
  };

  networking.hostName = "sirius";

  programs = {
    ssh.startAgent = true;
    zsh.enable = true;

    nix-ld = {
      enable = true;
      libraries = config.hardware.graphics.extraPackages;
      package = pkgs.nix-ld-rs;
    };

    dconf.enable = true;
  };

  services = {
    tailscale.enable = true;
  };

  fonts.packages = with pkgs; [(nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono"];})];

  system.stateVersion = "23.11";
}
