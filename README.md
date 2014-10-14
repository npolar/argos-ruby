# argos-ruby

A Ruby library and command-line tool accessing data from the [Argos](http://www.argos-system.org) tracking system operated by [CLS](http://www.cls.fr/welcome_en.html).

## argos-soap (webservice client)
See [[argos-soap]]

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

