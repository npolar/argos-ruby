module Argos

  # http://www.jcommops.org/dbcp/fmt-dbcp-m2.html
  # Used for?
  class DBCP_M2Decoder
    include SensorData

    @sensor_data_format = "hex"

    def data
      { chk: chk, rank: rank, ageb: ageb, bp: bp, sst: sst, apt: apt, at: at }
    end

    def chk
      extract(0,7)
    end

    def rank
      extract(8,11)
    end

    def ageb
      extract(12,17)
    end

    def bp
      (0.1 * extract(18,28)) + 850
    end

    # SST	Sea Surface Temp.
    def sst
      # 0.08 n - 5
      (0.08 * extract(29,37)) - 5
    end

    def apt
      (0.1 * extract(38,46)) - 25.5
    end

    def subm
      extract(47,52)
    end

    def vbat
      extract(53,55)
    end

    def wd
      3 * extract(56,62)
    end

    def ws
      extract(63,68)
    end

    # AT = Air Temperature
    # AT(°C) = 0.25 N - 20
    def at
      0.25 * extract(69,76) - 20
    end

    #  0.04 n - 5
    def tz
      0.04 * extract(88,97) - 5
    end

    def depth
      extract(98,105)
    end

    def pressures
      [66,77,88,99,110,121,132,143,154,165].map {|start|
        0.1 * bits(start, start+10) + 850
      }
    end

  end
end
