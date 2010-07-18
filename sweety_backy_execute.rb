require File.dirname(__FILE__) + "/sweety_backy.rb"

if( ARGV[0].nil? )
  puts "use: $ ruby sweety_backy_execute.rb <config_file_path>"
  exit 1
end

sb = SweetyBacky.new
sb.run( ARGV[1] )