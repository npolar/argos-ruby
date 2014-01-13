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

    def param(argv=ARGV)
      optparser = OptionParser.new(ARGV) do |opts|
    
        opts.banner = "argos-ruby [OPTIONS] {filename|glob}
        For more information and source: https://github.com/npolar/argos-ruby

Options:\n
        "
    
        opts.on_tail("--version", "-v", "Library version") do
          puts Argos.library_version
          exit
        end
      
        opts.on("--action=ACTION", "-a", "Action") do |action|
          param[:action] = action
        end
      
        opts.on("--filter=FILTER", "-f", "Filter") do |filter|
          param[:filter] = filter
        end
      
        opts.on("--level=LEVEL", "-l=LEVEL", "Log level") do |level|
      
          param[:level] = case level
            when /debug|0/i
              Logger::DEBUG
            when /info|1/i
              Logger::INFO
            when /warn|2/i
              Logger::WARN
            when /error|3/i
              Logger::ERROR
            when /fatal|4/i
              Logger::FATAL
            else
              param[:level]
          end
        end
      
      end
      optparser.parse!
    end

  end
end