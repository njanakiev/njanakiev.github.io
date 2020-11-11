---
title: "Systemd Cheatsheet"
category: blog
comments: True
image: /assets/systemd_cheatsheet_files/Activiteit_in_de_controle_kamer_in_de_Tap-Line_olie_terminal_nabij_Saida,_Bestanddeelnr_255-6308.jpg
imagesource: Wikimedia Commons
imageurl: https://commons.wikimedia.org/wiki/File:Activiteit_in_de_controle_kamer_in_de_Tap-Line_olie_terminal_nabij_Saida,_Bestanddeelnr_255-6308.jpg
layout: post
tags: ['Systemd', 'Server']
---
[Systemd](https://systemd.io/) is an [init](https://en.wikipedia.org/wiki/Init) system in Linux used for system intialization and service management. It is fairly useful to manage and monitor services. In this cheatsheet you will find a collection of common commands used with the command line tools `systemctl` and `journalctl`.

# Managing Systemd

- `systemctl list-units` list units and show if they are loaded and/or active
- `systemctl list-unit-files` list unit files and what status they have (enabled/disabled/static/...)
- `systemctl list-dependencies` list dependency tree
- `systemctl list-dependencies [SERVICE]` list dependencies of a unit

# Managing Services

- `systemctl status [SERVICE]` check status of service
- `systemctl show [SERVICE]` show service information
- `systemctl start [SERVICE]` start service
- `systemctl stop [SERVICE]` stop running service
- `systemctl restart [SERVICE]` restart service
- `systemctl reload [SERVICE]` reload service without stopping it
- `systemctl enable [SERVICE]` enable service to start at boot
- `systemctl disable [SERVICE]` disable service

# Viewing Logs

- `journalctl` View all logs
- `journalctl -u [SERVICE]` see logs of a single service
- `journalctl -u [SERVICE] -u [SERVICE 2]` see logs of more services
- `journalctl -u [SERVICE] -f` follow the logs of a single service

Filter by time with:

- `journalctl --since "1 hour ago"` entries logged in the last hour
- `journalctl --since "2 days ago"` entries logged in the last two days
- `journalctl --since "2 days ago" --until "1 day ago"` entries between two days ago and one day ago
- `journalctl --since "2020-01-01 00:00:00" --until "2020-01-05 12:30:00"` entries between two dates

Output arguments:

- `-o short-iso` show dates in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) time format
- `-o short-iso-precise` show dates in ISO 8601 time format including full microsecond precision 
- `-o cat` show only entries without timestamps
- `-o json` show each entry formatted as JSON line
- `-o json-pretty` display as pretty formatted JSON

Further arguments:

- `-b` show entries since last boot
- `-r` show entries in reverse chronological order
- `-n 50` show last 50 entries
- `--utc` show timestamps in UTC time
- `--no-hostname` don't show hostname field

# References

- https://systemd.io/
- man page for [journalctl](https://www.freedesktop.org/software/systemd/man/journalctl.html)
- man page for [systemctl](https://www.freedesktop.org/software/systemd/man/systemctl.html)
- [Understanding Systemd Units and Unit Files](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files)
- [How To Use Systemctl to Manage Systemd Services and Units](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)
- [How To Use Journalctl to View and Manipulate Systemd Logs](https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs)
- [systemd for Administrators, Part 1](http://0pointer.de/blog/projects/systemd-for-admins-1.html), [Part 2](http://0pointer.de/blog/projects/systemd-for-admins-2.html), [Part 3](http://0pointer.de/blog/projects/systemd-for-admins-3.html) by Lennart Poettering, the creator of systemd