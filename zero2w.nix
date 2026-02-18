{ ... }:
{
  imports = [
    ./sd-image.nix
    ./sd-defaults.nix
    ./hardware.nix
  ];

  # ! Need a trusted user for deploy-rs.
  nix.settings.trusted-users = [ "@wheel" ];
  system.stateVersion = "25.11";

  networking = {
    interfaces."wlan0".useDHCP = true;
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      # ! Change the following to connect to your own network
      networks = {
        "<ssid>" = {
          psk = "<ssid-key>";
        };
      };
    };
  };

  # Enable OpenSSH out of the box.
  services.sshd.enable = true;

  # NTP time sync.
  services.timesyncd.enable = true;

  # ! Change the following configuration
  users.users.bob = {
    isNormalUser = true;
    home = "/home/bob";
    description = "Bob";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    # ! Be sure to put your own public key here
    openssh.authorizedKeys.keys = [ "a public key" ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
  # ! Be sure to change the autologinUser.
  services.getty.autologinUser = "bob";

  # ! change the host name if you like
  networking.hostName = "pi";

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };
}
