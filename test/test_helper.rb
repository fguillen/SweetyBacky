require "#{File.dirname(__FILE__)}/../lib/sweety_backy"

require 'rubygems'
require 'fileutils'
require 'mocha'
require 'delorean'
require 'minitest/autorun'
require 'mocha/minitest'


FIXTURES_PATH = File.expand_path "#{File.dirname(__FILE__)}/fixtures"
