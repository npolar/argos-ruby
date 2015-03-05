require "simplecov"
SimpleCov.start

require "argos"

RSpec.configure do |config|
  
  # Use color in STDOUT
  config.color = true

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  # Use color not only in STDOUT but also in pagers and files
  config.tty = false

  # Use the specified formatter
  config.formatter =  :documentation #:progress,  :html, :textmate
end

def dsfile(filename)
  File.expand_path(File.dirname(__FILE__)+"/argos/_ds/#{filename}")
end

def diagfile(filename)
  File.expand_path(File.dirname(__FILE__)+"/argos/_diag/#{filename}")
end

