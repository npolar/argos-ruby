# argos-ruby

A Ruby library and command-line tool accessing data from the [Argos](http://www.argos-system.org) tracking system operated by ([CLS]http://www.cls.fr/welcome_en.html)

## argos-soap (webservice client)
The ``argos-soap`` command supports the full list of operations supported by the SOAP web service.

  $ argos-soap --operations
```json
["getCsv","getStreamXml","getKml","getXml","getXsd","getPlatformList","getObsCsv","getObsXml"]
```
The service delivers data in XML and CSV.

**All programs**
Data from all programs and all platforms are fetched by default

* $ argos-soap --operation=getXml > [getXml.xml](https://github.com/npolar/argos-ruby/blob/master/spec/argos/_soap/getXml.xml)
* $ argos-soap --operation=getXml --format=json > [getXml.json](https://github.com/npolar/argos-ruby/blob/master/spec/argos/_soap/getXml.json)
* $ argos-soap --operation=getKml > [getKml.xml](https://github.com/npolar/argos-ruby/blob/master/spec/argos/_soap/getKml.xml)
* $ argos-soap --operation=getCsv --format=text > [getCsv.csv](https://github.com/npolar/argos-ruby/blob/master/spec/argos/_soap/getCsv.csv)

**Select program(s)**
argos-soap --operation getXml --programNumber 9660

**Select platformId(s)**
$ argos-soap --operation getXml --platformId 81308

**Authentication**
Either set your credentials on the command line

  $ argos-soap --operation=getPlatformList --username=myusername --password=mypassword
  
Or set environmental variables ARGOS_SOAP_USERNAME and ARGOS_SOAP_PASSWORD

## Argos file parsing
### DS/DIAG to JSON
  $ # 

## About

[argos-ruby](https://github.com/npolar/argos-ruby) was developed to parse [Argos](http://www.argos-system.org)
satellite tracking data text files collected by the [Norwegian Polar Institute]
(http://npolar.no/en) since 1989. Be warned, the Argos text file formats have changed over time. No promises are
made that the library will work outside of Norway :).

Currently, the library parses Argos DS/DIAG files dating from August 1990 and onwards.

## Install
$ gem install argos-ruby

## Links

* https://github.com/npolar/api.npolar.no/wiki/Tracking-API-JSON
* [Argos User's Manual](http://www.argos-system.org/manual/)
* [Argos Web Service Interface Specification v1.4](http://www.argos-system.org/manual/argos_webservices-1_4.pdf)
* http://alaska.usgs.gov/science/biology/spatial/
* http://gis-lab.info/programs/argos/argos-manual-eng.html

