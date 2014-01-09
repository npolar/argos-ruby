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
$  ./bin/argos-ruby /tmp/990660_A.DAT
```
JSON output (shortened)

```json
[ { .. }, 
  {
    "program": 9660,
    "platform": 2173,
    "lines": 3,
    "sensors": 3,
    "satellite": "K",
    "lc": "B",
    "positioned": "1999-12-31T19:18:58Z",
    "latitude": 77.562,
    "longitude": 40.341,
    "altitude": 0.0,
    "headers": 12,
    "measured": "1999-12-31T19:19:28Z",
    "identical": 1,
    "sensor_data": [
      "18729",
      "17",
      "149"
    ],
    "technology": "argos",
    "type": "ds",
    "location": "file:///tmp/990660_A.DAT",
    "source": "3a39e0bd0b944dca4f4fbf17bc0680704cde2994",
    "parser": "argos-ruby-1.0.3",
    "id": "5185906d06859457786753459894bd33fdd8cd0a"
  }
]

```
Links
* [http://api.npolar.no/tracking/?q=&filter-technology=argos](http://api.npolar.no/tracking/?q=&filter-technology=argos)
* [Argos users manual v1.5](http://www.argos-system.org/files/pmedia/public/r363_9_argos_users_manual-v1.5.pdf) (PDF)
* http://alaska.usgs.gov/science/biology/spatial/
* http://gis-lab.info/programs/argos/argos-manual-eng.html