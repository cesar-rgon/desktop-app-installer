Thouse scripts works with old init.d service manager because LMDE 2 doesn't support systemd service manager yet.
So, thouse scripts mantain compatibility to be able to setup correctly next daemons: Deluge daemon, qBittorrent daemon and Transmission daemon.
Amule daemon is excluded because is not present on LMDE 2 default repositories.

Those scripts use subscripts located in folder scriptRootFolder/etc/old-init.d/*
