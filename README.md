# argos-ruby

[argos-ruby](https://github.com/npolar/argos-ruby) contains tools for working with
[Argos](http://www.argos-system.org) satellite tracking data and services:

* Parsers for Argos legacy ASCII (DS/DAT and DIAG/DIA files)
* SOAP web service client
* Web service download tool
* JSON conversion from ASCII and XML

Developed by staff at the [Norwegian Polar Data Centre](http://data.npolar.no), [Norwegian Polar Institute](http://npolar.no).

## Webservice

```sh
$ argos-soap -o getXsd # does not require authentication
$ argos-soap --download archive/tracking/CLS  --username=USERNAME --password=PASSWORD --debug
$ argos-soap -o getXml --username=USERNAME --password=PASSWORD

```

See [argos-soap](https://github.com/npolar/argos-ruby/wiki/argos-soap) for more usage examples.

### Legacy file parsing

```sh
$ argos-ascii spec/argos/_ds/*.DAT
$ argos-ascii --action=source "spec/argos/_d*"
$ argos-ascii --filter='lambda {|d| d[:program] == 9660 and d[:platform] == 2189 }' spec/argos/_ds/990660_A.DAT
```
The **source** action provides a metadata summary, list of programs, platforms, etc.

### JSON (via XSLT)
```sh
$ xsltproc lib/argos/_xslt/argos-json.xslt spec/argos/_soap/getXml.xml 
```

## Install
```sh
$ gem install argos-ruby
$ cd `gem environment gemdir`/gems/argos-ruby-1.2.4
$ bundle install
```
Note: The extra step is a [bug](https://github.com/npolar/argos-ruby/issues/1)

## Links
* https://github.com/npolar/api.npolar.no/wiki/Tracking-API-JSON
* [Argos User's Manual](http://www.argos-system.org/manual/)
* [Argos Web Service Interface Specification v1.4](http://www.argos-system.org/manual/argos_webservices-1_4.pdf)
* http://alaska.usgs.gov/science/biology/spatial/
* http://gis-lab.info/programs/argos/argos-manual-eng.html
* [CLS](http://www.cls.fr/welcome_en.html) - operates the Argos system
