{ pkgs, ... }: {
  virtualisation.oci-containers = {
    containers.photoviewer = {
      image = "photoview/photoview:2";
      ports = [ "127.0.0.1:8080:8080" ];
      volumes = [
        "photoviewer-database:/home/photoview/database"
        "/media/photos:/home/photoview/photos"
      ];
      environment = {
        PHOTOVIEW_LISTEN_PORT = "8080";
        PHOTOVIEW_DATABASE_DRIVER = "sqlite";
        PHOTOVIEW_SQLITE_PATH = "/home/photoview/database/photoview.db";
      };
    };
  };

  security.acme.certs."photos.thenoodledragonlair.com" = {
    dnsProvider = "dreamhost";
    environmentFile = "/var/lib/acme_secret/dreamhost_env";
  };

  systemd.timers.restart-photoviewer = {
    timerConfig = {
      Unit = "restart-photoviewer.service";
      OnCalendar = "Tue 02:00";
    };
    wantedBy = [ "timers.target" ];
  };
  systemd.services.restart-photoviewer = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl try-restart podman-photoviewer.service";
    };
  };
}
