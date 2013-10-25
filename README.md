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
$ 

## Command-line usage
```sh
$  curl "https://raw.github.com/npolar/argos-ruby/master/spec/argos/_ds/990660_A.DAT" > /tmp/990660_A.DAT
$  argos-json /tmp/990660_A.DAT "lambda {|a| a[:program] == 660 }"

```
$ ./bin/argos-json /tmp/990660_A.DAT "lambda {|a| a[:program] == 660 }"
I, [2013-10-25T11:11:22.330110 #6870]  INFO -- : Unfolded 1 ARGOS DS position and sensor messages into 1 new documents source:3a39e0bd0b944dca4f4fbf17bc0680704cde2994 /tmp/990660_A.DAT
I, [2013-10-25T11:11:22.330182 #6870]  INFO -- : Documents: 1, ds: 1, diag: 0, bundle: 831dcea3f5cb413f3526d6b5f39ce348a6c6ad17, glob: /tmp/990660_A.DAT
```
This will output (the "lambda" is of course optional):
``` json
[{"program":660,"platform":14747,"lines":2,"sensors":32,"satellite":"K","lc":null,"positioned":null,"latitude":null,"longitude":null,"altitude":null,"headers":5,"measured":"1999-12-16T00:46:49Z","identical":1,"sensor_data":["92","128","130","132"],"technology":"argos","type":"ds","filename":"/tmp/990660_A.DAT","source":"3a39e0bd0b944dca4f4fbf17bc0680704cde2994","errors":["missing-position","sensors-count-mismatch"],"valid":false,"parser":"a23f82183ff777c339279dac3fb627f5c2d4745f","id":"f2c82a5ca1330b312925949a15ac300d07452a12"}]
```
Links
* [api.npolar.no/tracking](http://api.npolar.no/tracking/?q=)
* [Argos users manual v1.5](http://www.argos-system.org/files/pmedia/public/r363_9_argos_users_manual-v1.5.pdf)
