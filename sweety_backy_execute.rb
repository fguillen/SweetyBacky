require 'benchmark'
require File.dirname(__FILE__) + "/sweety_backy.rb"

if( ARGV[0].nil? )
  puts "use: $ ruby sweety_backy_execute.rb <config_file_path>"
  exit 1
end

lapsus_time = 
  Benchmark.realtime do
    sb = SweetyBacky.new
    sb.run( ARGV[0] )
  end

puts "SweetyBacky on #{lapsus_time}"