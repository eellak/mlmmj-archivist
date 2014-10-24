# mlmmj-archivist

A shell script for creating web archives for mlmmj mailing lists.

## Features

- Supports flat and hierarchical mailing list directory structures; eg. both /var/spool/mlmmj/listname and /var/spool/mlmmj/domain.tld/listname are supported.
- Theming support (WIP).
- Localization support (WIP).
- Also creates introduction pages for the domain and each mailing list.

## Requirements

- [MHonArc](http://mhonarc.org).
- Basic UNIX utilities: awk, cat, grep, install, sed and, of course, sh.

## License

This project is licensed under the [ISC license](http://opensource.org/licenses/ISC).
