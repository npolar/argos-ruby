# argos-ruby

A Ruby library and command-line tool for parsing Argos tracking data


## Usage
### DS/DIAG to JSON

```argos-ruby``` converts Argos files to JSON. DS header data is repeated in each message
```sh
curl "https://raw.github.com/npolar/argos-ruby/master/spec/argos/_ds/fragment.ds" > /tmp/fragment.ds
argos-ruby /tmp/fragment.ds 
```
```json
[
  {
    "program": 9660,
    "platform": 10783,
    "lines": 3,
    "sensors": 3,
    "satellite": "K",
    "lc": "3",
    "positioned": "1999-12-30T17:58:26Z",
    "latitude": 79.824,
    "longitude": 22.363,
    "altitude": 0.0,
    "headers": 12,
    "measured": "1999-12-30T17:56:30Z",
    "identical": 2,
    "sensor_data": [
      "78",
      "00",
      "00"
    ],
    "technology": "argos",
    "type": "ds",
    "location": "file:///tmp/fragment.ds",
    "source": "a9c02cf81978a9fafecac582309c7c8161e5a76c",
    "parser": "argos-ruby-1.0.3",
    "id": "2d833010d13714dfb771f73470417405b887e8f4"
  },
  {
    "program": 9660,
    "platform": 10783,
    "lines": 3,
    "sensors": 3,
    "satellite": "K",
    "lc": "3",
    "positioned": "1999-12-30T17:58:26Z",
    "latitude": 79.824,
    "longitude": 22.363,
    "altitude": 0.0,
    "headers": 12,
    "measured": "1999-12-30T18:01:20Z",
    "identical": 5,
    "sensor_data": [
      "78",
      "00",
      "00"
    ],
    "technology": "argos",
    "type": "ds",
    "location": "file:///tmp/fragment.ds",
    "source": "a9c02cf81978a9fafecac582309c7c8161e5a76c",
    "parser": "argos-ruby-1.0.3",
    "id": "26af9092d01fbd49ff8cb9041e63df352886dba6"
  }
]
```

## About

[argos-ruby](https://github.com/npolar/argos-ruby) is used to parse [Argos](http://www.argos-system.org)
satellite tracking data files collected at the [Norwegian Polar Institute]
(http://npolar.no/en) since 1989.

Be warned, the Argos file formats have changed over time. No promises are
made that the library will work outside of Norway :).

Currently, the library parses Argos DS/DIAG files dating from August 1990
and onwards.

## Install
$ gem install argos-ruby

## Links
* [http://api.npolar.no/tracking/?q=&filter-technology=argos](http://api.npolar.no/tracking/?q=&filter-technology=argos)
* [Argos users manual v1.5](http://www.argos-system.org/files/pmedia/public/r363_9_argos_users_manual-v1.5.pdf) (PDF)
* http://alaska.usgs.gov/science/biology/spatial/
* http://gis-lab.info/programs/argos/argos-manual-eng.html