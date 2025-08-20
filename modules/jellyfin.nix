{ pkgs, ... }: {
  services.jellyfin = {
    enable = true;
  };

  security.acme.certs."media.thenoodledragonlair.com" = {
    dnsProvider = "dreamhost";
    environmentFile = "/var/lib/acme_secret/dreamhost_env";
  };
}
