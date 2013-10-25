# argos-ruby

A Ruby library for parsing Argos tracking data

```argos-ruby``` has been developed to parse [Argos](http://www.argos-system.org)
satellite tracking data collected at the [Norwegian Polar Institute]
(http://npolar.no/en) over a 25-year period (!) from 1989 to 2013.

Be warned, the Argos file formats have changed over time. No promises are
made that the library will work outside Norway :).

Currently, the library parses Argos DS/DAT and DIAG/DIA files dating from 1991
and onwards.

## Install
$ sudo gem install argos-ruby

## Command-line usage
```sh
$  curl "http://localhost/990660_A.DAT" > /tmp/990660_A.DAT
$  argos parse /tmp/990660_A.DAT "lambda {|a| a[:program] == 660 }"

```

Links
* [api.npolar.no/tracking](http://api.npolar.no/tracking/?q=)
* [Argos users manual v1.5](http://www.argos-system.org/files/pmedia/public/r363_9_argos_users_manual-v1.5.pdf)
