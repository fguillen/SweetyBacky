require 'benchmark'
require File.dirname(__FILE__) + "/sweety_backy.rb"

if( ARGV[0].nil? )
  Utils::log "use: $ ruby sweety_backy_execute.rb <config_file_path>"
  exit 1
end

lapsus_time = 
  Benchmark.realtime do
    Utils::log "--------------------"
    Utils::log "Starting SweetyBacky"
    sb = SweetyBacky.new( ARGV[0] )
    sb.run
  end

Utils::log "SweetyBacky on #{lapsus_time} seconds"