require "optparse"

module Argos
  class Command

    attr_accessor :param

    PARAM_DEFAULT = { format: "json",
      action: "parse",
      level: Logger::WARN,
      dest: nil,
      filter: nil,
    }

    def initialize
      @param = PARAM_DEFAULT
    end

    

  end
end