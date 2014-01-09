# argos-ruby

A Ruby library for parsing Argos tracking data

[argos-ruby](https://github.com/npolar/argos-ruby) is used to parse [Argos](http://www.argos-system.org)
satellite tracking data files collected at the [Norwegian Polar Institute]
(http://npolar.no/en) since 1989.

Be warned, the Argos file formats have changed over time. No promises are
made that the library will work outside of Norway :).

Currently, the library parses Argos DS/DIAG files dating from August 1990
and onwards.

## Install
$ gem install argos-ruby

## Command-line usage
```sh
$  curl "https://raw.github.com/npolar/argos-ruby/master/spec/argos/_ds/990660_A.DAT" > /tmp/990660_A.DAT
$  ./bin/argos-ruby /tmp/990660_A.DAT --filter "lambda {|a| a[:program] == 660 }"
```
This will output (the lambda filter is of course optional):

```json
[
  {
    "program": 660,
    "platform": 14747,
    "lines": 2,
    "sensors": 32,
    "satellite": "K",
    "lc": null,
    "positioned": null,
    "latitude": null,
    "longitude": null,
    "altitude": null,
    "headers": 5,
    "measured": "1999-12-16T00:46:49Z",
    "identical": 1,
    "sensor_data": [
      "92",
      "128",
      "130",
      "132"
    ],
    "technology": "argos",
    "type": "ds",
    "location": "file:///tmp/990660_A.DAT",
    "source": "3a39e0bd0b944dca4f4fbf17bc0680704cde2994",
    "warn": [
      "missing-position",
      "sensors-count-mismatch"
    ],
    "parser": "argos-ruby-1.0.2",
    "id": "f12fe18341430f1db0fcf04fae314421c13369a6"
  }
]
```
Links
* [http://api.npolar.no/tracking/?q=&filter-technology=argos](http://api.npolar.no/tracking/?q=&filter-technology=argos)
* [Argos users manual v1.5](http://www.argos-system.org/files/pmedia/public/r363_9_argos_users_manual-v1.5.pdf) (PDF)
http://alaska.usgs.gov/science/biology/spatial/pdfs/argosfilter_v850_manual.pdf
http://gis-lab.info/programs/argos/argos-manual-eng.html#delimit
http://alaska.usgs.gov/science/biology/spatial/