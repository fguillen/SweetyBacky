begin
  require 's3'
rescue LoadError
  require 'rubygems'
  require 's3'
end

require 'digest/md5'

require "#{File.dirname(__FILE__)}/sweety_backy/version"
require "#{File.dirname(__FILE__)}/sweety_backy/runner"
require "#{File.dirname(__FILE__)}/sweety_backy/utils"
require "#{File.dirname(__FILE__)}/sweety_backy/commander"
require "#{File.dirname(__FILE__)}/sweety_backy/s3"
require "#{File.dirname(__FILE__)}/sweety_backy/opts_reader"
