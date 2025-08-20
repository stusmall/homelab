{ pkgs, ... }: {
  services.haproxy = {
    enable = true;
    group = "acme";
    config = ''
      frontend photos.thenoodledragonlair.com
          mode http
          bind 100.92.141.18:80
          bind 100.92.141.18:443 ssl crt /var/lib/acme/photos.thenoodledragonlair.com/full.pem
          http-request redirect scheme https unless { ssl_fc }
          default_backend photos
      frontend media.thenoodledragonlair.com
          mode http
          bind 100.92.141.18:80
          bind 100.92.141.18:443 ssl crt /var/lib/acme/media.thenoodledragonlair.com/full.pem
          http-request redirect scheme https unless { ssl_fc }
          default_backend media

      backend photos
          mode http
          server photos :8080 check
      backend media
        mode http
        server media :8096 check
    '';

  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
