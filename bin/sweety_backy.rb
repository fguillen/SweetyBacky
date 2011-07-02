require 'benchmark'
# require 'sweety_backy'
require File.dirname(__FILE__) + "/../lib/sweety_backy"

if( ARGV[0].nil? )
  SweetyBacky::Utils.log "use: $ ruby sweety_backy.rb <config_file_path>"
  exit 1
end

lapsus_time = 
  Benchmark.realtime do
    SweetyBacky::Utils.log "--------------------"
    SweetyBacky::Utils.log "Starting SweetyBacky"
    sb = SweetyBacky::Runner.new( ARGV[0] )
    sb.run
  end

SweetyBacky::Utils.log "SweetyBacky on #{lapsus_time} seconds"