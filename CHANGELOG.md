## 0.6.0

* Generate SSH keys (instead of copying - bad!)
* Added use_local_ssh_id flag to machines.yml instead of generating one every time (for testing)
* Configure Chrome/Chromium download directory
* Don't terminate on file upload errors (missing source or dest)
* Display better message when initial connection fails
* documented some generated settings
* Added dwm (Dynamic Window Manager) package
* Some fixes to mysql package
* Some updates for Ubuntu 13.04 (this may break older distros)
* A load more fixes

## 0.5.6

* Gem updates - spec_helper updated to handle features removed from minitest
* Fixed bug introducted in API cleanup where commands were not included in Core

## 0.5.5

* Cleaned up API - moved all commands into Commands module and turned non-commands into classes
* Switched to dwm and slim for default template window manager/login manager
* Added make clean install to `install` command
* BUG: fixed incorrect link command in timezone package

## 0.5.4

* Added support extracting for bz2 archives
* `install` can now download an archive and extract to /usr/local/lib and create a link in /usr/local/bin


## 0.5.3

* Implement `list` command to list available machines from machines.yml
* Display syntax when `build` called with no machine
* Support running multiple tasks - e.g. `machines build machine passenger passenger_nginx nginx webapps`
* modify git_clone to pull if the repo already exists

## 0.5.2

* Bug fixes


## 0.5.1

* Added opensource flag to allow alternatives to be installed (e.g. Chrome/Chromium)
* Added config.yml option to autostart VBoxClient for WMs that don't use XDG autostart
* Only append lines in a file if they do not exist (allows repeat running of commands)
