{ config, lib, ... }:

{

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;
  networking.hostName = "node-1";
  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [ "stusmall" ];
    };
  };

  users.users.stusmall = {
    isNormalUser = true;
    description = "Stuart Small";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXvDVfUlSpHGbL2uVPuEuTVyYWAC3f0eJJjAWyZI2gkFEFFCzVhKGL1VII0iN6pxkmWhygsUMJnS0TvHXI0TXQIG1Yd1qAC34cAG5Nasm6oTMi+fmyy+kjncstLHCB8theLEBQgTPfJHBbX+5v/O6hFkYTdUUG8KvMcjnNVwIrVXolgZWdf6ivdBYiAZFyYA6nnGBEknzPnYfmRmf3wNZVYq1iqybpNc7zSl65x7MiRUpjDWVpM3e++mAG7pZ5KCzoYh0oVa0QBMpJUYUw9DjvtPSnptdKEoy7e0Seh7eCkOmLFxk5W+P9o843W28UdIcbkqXlhgFUZMMHdAu5kCG16Y+g5bcsGxEUIX50+opIH4BGs82leheGoX8USwYRzIaVTYCKDg57WmPn2gLZZIgUXR2j1/DKDOfqpe3Kpw2y9vh/krGvld9ttEAugjEfEPozvaXlg3wJj8/BHXlVzeeDg5WXcRYdlLQ5YijY1UxpKOG84GLstc2LKSYotIkBKceipt0qp18rEo2PhVB0CPYVStVawYQMs+E8RlSOyNhpQ9MYFcu7TAkc1esExPlVybbiGes2OM+dyouGOn6luitCOMo48EyItYIvrrtdySHpcAS9Dg8C9FyUt05yuxaU+A2smvO9boAhBA2lk4GXCxrkH61R7WKtoGDz+4YLh8YJCQ== cardno:13_069_997"
    ];
  };

  # Docker images updates on Monday, system updates on Tuesday
  system.autoUpgrade = {
    enable = true;
    dates = "Tue 03:00";
    operation = "switch";
  };

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8ef64ba0-3df2-4491-ad41-03450ac34247";
    fsType = "ext4";
  };

  fileSystems."/media" = {
    device = "/dev/disk/by-uuid/af334612-c8bc-4e27-9011-ece39256e46a";
    fsType = "ext4";
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp34s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
