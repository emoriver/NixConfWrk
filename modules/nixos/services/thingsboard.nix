{ config, pkgs, lib, ... }:

{
  options.enableThingsboard = lib.mkEnableOption "Enable ThingsBoard IoT platform";

  config = lib.mkIf config.enableThingsboard {
    # ----- utente di sistema (dichiarativo, al posto di useradd) -----
    users.groups.thingsboard = { };
    users.users.thingsboard = {
      isSystemUser = true;
      group = "thingsboard";
      description = "ThingsBoard service user";
      home = "/var/lib/thingsboard";
    };

    # ----- directory scrivibili -----
    # NB: /usr/share/thingsboard (binari .deb estratti) resta gestito a mano,
    # vedi guida di installazione una tantum.
    systemd.tmpfiles.rules = [
      "d /var/lib/thingsboard/conf 0750 thingsboard thingsboard -"
      "d /var/log/thingsboard      0750 thingsboard thingsboard -"
    ];

    # Java richiesto per l'avvio manuale/di installazione
    environment.systemPackages = [ pkgs.jdk21 ];

    # ----- servizio permanente (niente /run/systemd/system) -----
    systemd.services.thingsboard = {
      description = "ThingsBoard IoT Platform";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "thingsboard";
        Group = "thingsboard";
        # File NON gestito da Nix (contiene la password del DB):
        # va creato a mano su /var/lib/thingsboard/conf/thingsboard.env
        EnvironmentFile = "/var/lib/thingsboard/conf/thingsboard.env";
        ExecStart = ''${pkgs.jdk21}/bin/java \
          -Dplatform=deb \
          -Dinstall.data_dir=/usr/share/thingsboard/data \
          -Xlog:gc*,heap*,age*,safepoint=debug:file=/var/log/thingsboard/gc.log:time,uptime,level,tags:filecount=10,filesize=10M \
          -XX:+IgnoreUnrecognizedVMOptions -XX:+HeapDumpOnOutOfMemoryError \
          -XX:+UseG1GC -XX:MaxGCPauseMillis=500 \
          -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled \
          -Dloader.path=/usr/share/thingsboard/conf,/usr/share/thingsboard/extensions \
          -Dspring.config.location=file:/usr/share/thingsboard/conf/thingsboard.yml \
          -jar /usr/share/thingsboard/bin/thingsboard.jar'';
        WorkingDirectory = "/usr/share/thingsboard";
        SuccessExitStatus = 143;
        Restart = "always";
        RestartSec = 30;
      };
    };
  };
}
