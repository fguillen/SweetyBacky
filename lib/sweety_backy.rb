begin
  require 'aws-sdk'
rescue LoadError
  require 'rubygems'
  require 'aws-sdk'
end

require 'digest/md5'

require "#{File.dirname(__FILE__)}/sweety_backy/version"
require "#{File.dirname(__FILE__)}/sweety_backy/runner"
require "#{File.dirname(__FILE__)}/sweety_backy/utils"
require "#{File.dirname(__FILE__)}/sweety_backy/commander"
require "#{File.dirname(__FILE__)}/sweety_backy/s3"
require "#{File.dirname(__FILE__)}/sweety_backy/opts_reader"
