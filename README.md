# argos-ruby

[argos-ruby](https://github.com/npolar/argos-ruby) contains tools for working with
[Argos](http://www.argos-system.org) satellite tracking data and services:

* Parsers for Argos ASCII files (DS/DAT and DIAG/DIA files)
* SOAP web service client
* Web service download tool
* Sensor data decoders

argos-ruby is developed by staff at the [Norwegian Polar Data Centre](http://data.npolar.no).

The library is fully unit tested and used in production in various Tracking APIsthe [Tracking APIs](https://github.com/npolar/api.npolar.no/wiki/Tracking-APIs).

[![Code Climate](https://codeclimate.com/github/npolar/argos-ruby/badges/gpa.svg)](https://codeclimate.com/github/npolar/argos-ruby)

## Argos ASCII to JSON
The command-line tool ```argos-ascii``` converts DS or DIAG files to JSON using the ruby classes Argos::Ds and Argos::Diag.
The data conversion in mostly Regexp-based so could easily be ported to other programming languages.

Examples
```sh
$ argos-ascii spec/argos/_ds/*.DAT
$ argos-ascii --action=source "spec/argos/_d*"
$ argos-ascii --filter='lambda {|d| d[:program] == 9660 and d[:platform] == 2189 }' spec/argos/_ds/990660_A.DAT
```
The **source** action provides a metadata summary, list of programs, platforms, etc.

See [argos-ascii](https://github.com/npolar/argos-ruby/wiki/argos-ascii) or run ```argos-ascii``` for documentation.

## SOAP webservice client
The command-line tool ```argos-soap``` provides access to all operations (as of v1.4) in the Argos SOAP webservice.

See [argos-soap](https://github.com/npolar/argos-ruby/wiki/argos-soap) or run ```argos-soap```for command-help.

Examples
```sh
$ argos-soap -o getXsd # does not require authentication
$ argos-soap -o getXml --username=USERNAME --password=PASSWORD
$ argos-soap -o getPlatformList --username=USERNAME --password=PASSWORD

```

### Download tool

The argos-soap command also contains a convient download tool, that runs the getXml operation for each platform for each of the last 20 days.
The download tool creates one XML data file per platform per day, stored in a file structure like

* /path/to/tracking/archive/argos/xml/$year/program-$program/platform-$platform/argos-$year-$mm-$dd-platform-$platform.xml
* /path/to/tracking/archive/argos/xml/2015/program-9660/platform-2180/argos-2015-03-06-platform-2180.xml

```sh
$ argos-soap --download /path/to/tracking/archive/argos/xml --username=USERNAME --password=PASSWORD --debug

```

## Argos XML to JSON

```sh
$ ./bin/argos-json-xslt /path/to/argos-data.xml
$ xsltproc lib/argos/_xslt/argos-json.xslt spec/argos/_soap/getXml.xml
```

## Sensor data decoding
* [NorthStar4BytesDecoder]
* [KiwiSat303Decoder](https://github.com/npolar/argos-ruby/wiki/KiwiSat303Decoder)

## Install

```sh
$ gem install argos-ruby
$ cd `gem environment gemdir`/gems/argos-ruby-1.6.0
$ bundle install
```
Note: The extra step is a [bug](https://github.com/npolar/argos-ruby/issues/1)

## Links
* [Argos User's Manual](http://www.argos-system.org/manual/)
* [Argos Web Service Interface Specification v1.7](http://www.argos-system.org/files/pmedia/public/r1626_9_argos_webservices-1_7.pdf) [issued 2015-09-25]
* http://alaska.usgs.gov/science/biology/spatial/
* http://gis-lab.info/programs/argos/argos-manual-eng.html
* [CLS](http://www.cls.fr/welcome_en.html) - operates the Argos system
