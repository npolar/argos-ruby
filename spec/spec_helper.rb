require "argos"

RSpec.configure do |config|
  # Use color in STDOUT
  config.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter =  :documentation #:progress,  :html, :textmate
end

def dsfile(filename)
  File.expand_path(File.dirname(__FILE__)+"/argos/_ds/#{filename}")
end

def diagfile(filename)
  File.expand_path(File.dirname(__FILE__)+"/argos/_diag/#{filename}")
end

