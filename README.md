# mlmmj-archivist

A shell script for creating web archives for mlmmj mailing lists.

## Features

- Supports flat and hierarchical mailing list directory structures; eg. both `/var/spool/mlmmj/listname` and `/var/spool/mlmmj/domain.tld/listname` structures are supported.
- Theming support.
- Localization support.
- Also creates introduction pages for the domain and each mailing list.

## Requirements & Compatibility

- [MHonArc](http://mhonarc.org).
- [rsync](http://rsync.samba.org/).
- Basic UNIX utilities: awk, cat, date, grep, install, sed and, of course, sh.

Tested on Debian Wheezy. Currently it requires GNU date so it is not very portable. Should fix this in a future update.

The current Makefile requires GNU make. In future versions it should work with BSD make too.

## Installation

Running

<pre><code>make install</code></pre>

should install the script in `/usr/local/bin`, the configuration samples in `/etc/mlmmj-archivist` and the bundled templates in `/usr/local/share/mlmmj-archivist/templates`.

All paths can be adjusted by setting the environment variables:

- `SYSCONFDIR`: for the configuration directory.
- `PREFIX`: for replacing `/usr/local` with something else.
- `BINDIR`: the installation path for the executable script.
- `SHAREDIR`: the shared directory; currently contains the templates directory.
- `DESTDIR`: the root directory to work on. Useful for packaging.

After completing the installation you should copy the configuration files `mlmmj-archivist.conf.sample` to `mlmmj-archivist.conf`, and `mhonarc.mrc.sample` to `mhonarc.mrc`, and tweak to your preference, prior to running the script for first time.

## Usage

`mlmmj-archivist` is designed to run from cron in predefined intervals. Since it creates archives recursively it can be used with frequent intervals in busy hosts with many mailing list messages.

An example crontab entry for running `mlmmj-archivist` hourly:

<pre><code>5 * * * *  /usr/local/bin/mlmmj-archivist</code></pre>

## TODO

- Add parallel archive creation capability, for SMP systems.
- Switch the localization system to something less hackish; gettext is a good candidate.

## License

This project is licensed under the [ISC license](http://opensource.org/licenses/ISC).
