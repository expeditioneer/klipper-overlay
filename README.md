# klipper gentoo overlay 

[![Build Status](https://github.com/expeditioneer/klipper-overlay/actions/workflows/pkgcheck.yml/badge.svg)](https://github.com/expeditioneer/klipper-overlay/actions/workflows/pkgcheck.yml)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/expeditioneer/klipper-overlay/graphs/commit-activity)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

This repo provides necessary ebuilds to set up the 3D printer firmware with [Klipper](https://www.klipper3d.org/), [Moonraker](https://github.com/Arksine/moonraker) and [Fluidd](https://github.com/cadriel/fluidd).

## List of ebuilds
  - app-misc/klipper
  - app-misc/moonraker
  - media-video/mjpg-streamer  
  - www-apps/fluidd

Feel free to contribute!

## Using with Portage
Create a new config file under `/etc/portage/repos.conf/klipper.conf` with the following contents:
```ini
[klipper]
auto-sync = yes
location = /var/db/repos/klipper
sync-type = git
sync-uri = https://github.com/expeditioneer/klipper-overlay.git
```
You may adapt the `location` attribute to your system's own setup.

## Bug reports and ebuild requests

If you find a bug in an ebuild, encounter a build error or would like me to add a new ebuild, please open an issue on [GitHub](https://github.com/expeditioneer/klipper-overlay/issues).

## Contributing

I gladly accept pull requests for bugs or new ebuilds. Before opening a pull request, please make sure your changes don't upset [`pkgcheck`](https://github.com/pkgcore/pkgcheck). Run the following command and fix warnings and errors:
```shell
pkgcheck scan
```
## Acknowledgements

Thanks go to Jakub Jirutka, the maintainer of the [CVUT Overlay](https://github.com/cvut/gentoo-overlay), from whom I shamelessly copied this README.md for a start.
