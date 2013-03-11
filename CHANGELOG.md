== 0.5.5

* Cleaned up API - moved all commands into Commands module and turned non-commands into classes

== 0.5.4

* Added support extracting for bz2 archives
* `install` can now download an archive and extract to /usr/local/lib and create a link in /usr/local/bin


== 0.5.3

* Implement `list` command to list available machines from machines.yml
* Display syntax when `build` called with no machine
* Support running multiple tasks - e.g. `machines build machine passenger passenger_nginx nginx webapps`
* modify git_clone to pull if the repo already exists

== 0.5.2

* Bug fixes


== 0.5.1

* Added opensource flag to allow alternatives to be installed (e.g. Chrome/Chromium)
* Added config.yml option to autostart VBoxClient for WMs that don't use XDG autostart
* Only append lines in a file if they do not exist (allows repeat running of commands)
