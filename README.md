# argos-ruby

[argos-ruby](https://github.com/npolar/argos-ruby) contains tools for working with
[Argos](http://www.argos-system.org) satellite tracking data and services:

* Parsers for Argos ASCII files (DS/DAT and DIAG/DIA files)
* SOAP web service client (argos-soap)
* Web service download tool

Developed by staff at the [Norwegian Polar Data Centre](http://data.npolar.no), for use in the [Telemetry API](https://github.com/npolar/api.npolar.no/wiki/Tracking-API)

## Argos ASCII to JSON

```sh
$ argos-ascii spec/argos/_ds/*.DAT
$ argos-ascii --action=source "spec/argos/_d*"
$ argos-ascii --filter='lambda {|d| d[:program] == 9660 and d[:platform] == 2189 }' spec/argos/_ds/990660_A.DAT
```
The **source** action provides a metadata summary, list of programs, platforms, etc.

See [argos-ascii](https://github.com/npolar/argos-ruby/wiki/argos-ascii) for more usage examples.

## SOAP webservice client

```sh
$ argos-soap -o getXsd # does not require authentication
$ argos-soap --download /path/to/archive/tracking/CLS  --username=USERNAME --password=PASSWORD --debug
$ argos-soap -o getXml --username=USERNAME --password=PASSWORD

```
See [argos-soap](https://github.com/npolar/argos-ruby/wiki/argos-soap) for more usage examples.

Convert Argos data XML to JSON (using XSLT)
```sh
$ xsltproc lib/argos/_xslt/argos-json.xslt spec/argos/_soap/getXml.xml 
```

## Install
```sh
$ gem install argos-ruby
$ cd `gem environment gemdir`/gems/argos-ruby-1.3.0
$ bundle install
```
Note: The extra step is a [bug](https://github.com/npolar/argos-ruby/issues/1)

## Links
* https://github.com/npolar/api.npolar.no/wiki/Tracking-API
* [Argos User's Manual](http://www.argos-system.org/manual/)
* [Argos Web Service Interface Specification v1.4](http://www.argos-system.org/manual/argos_webservices-1_4.pdf)
* http://alaska.usgs.gov/science/biology/spatial/
* http://gis-lab.info/programs/argos/argos-manual-eng.html
* [CLS](http://www.cls.fr/welcome_en.html) - operates the Argos system