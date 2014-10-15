# argos-ruby

[argos-ruby](https://github.com/npolar/argos-ruby) contains tools to work with
[Argos](http://www.argos-system.org) satellite tracking data and services

Contains
* Parsers for Argos legacy ASCII files (DS/DAT and DIAG/DIA files)
* Soap web service client
* Soap download tool
* XSLT to produce JSON of Argos data XML

Developed by staff at the [Norwegian Polar Data Centre](http://data.npolar.no), [Norwegian Polar Institute](http://npolar.no).

## Webservice

```sh
$ argos-soap --download archive/tracking/CLS  --username=USERNAME --password=PASSWORD --debug
$ argos-soap -o getXml --username=USERNAME --password=PASSWORD

```

### Legacy file

```sh
$ argos-ascii spec/argos/_ds/*.DAT 
$  argos-ascii --action=source "spec/argos/_d*"
```
The **source** action provides a metadata summary, list of programs, platforms, etc.

## Install
```sh
$ gem install argos-ruby
```

## Links
* https://github.com/npolar/api.npolar.no/wiki/Tracking-API-JSON
* [Argos User's Manual](http://www.argos-system.org/manual/)
* [Argos Web Service Interface Specification v1.4](http://www.argos-system.org/manual/argos_webservices-1_4.pdf)
* http://alaska.usgs.gov/science/biology/spatial/
* http://gis-lab.info/programs/argos/argos-manual-eng.html
* [CLS](http://www.cls.fr/welcome_en.html) - operates the Argos system
