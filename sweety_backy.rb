require 'rubygems'
require 'fileutils'
require 'tmpdir'
require File.dirname(__FILE__) + "/utils.rb"

class SweetyBacky
  
  def initialize( conf_path )
    @opts = Utils::read_opts( conf_path )
    puts "configuration: #{@opts.inspect}"
  end
  
  def do_backup
    block = ""
    if( Utils::is_last_day_of_year? )
      block = 'yearly'      
    elsif( Utils::is_last_day_of_month? )
      block = 'monthly'
    elsif( Utils::is_last_day_of_week? )
      block = 'weekly'
    else
      block = 'daily'
    end
    
    # files
    path = "#{@opts[:path]}/files/#{Date.today.strftime('%Y%m%d')}.#{block}.tar.gz"
    self.do_files_backup( path )
    
    # databases
    path = "#{@opts[:path]}/databases/#{Date.today.strftime('%Y%m%d')}.#{block}.sql.tar.gz"
    self.do_databases_backup( path )
  end
  
  def do_files_backup( path )
    puts "doing files backup"
    
    FileUtils.mkdir_p( File.dirname( path ) )
    exclude_file_path = File.join( Dir::tmpdir, "#{Time.now.to_i}_exclude.txt" )
    File.open( exclude_file_path, 'w' ) { |f| f.write @opts[:excludes].join("\n") }
    Utils::command( "#{@opts[:tar_path]} -cz --same-permissions --file #{path} --exclude-from #{exclude_file_path} #{@opts[:includes].join(' ')}" )
  end
  
  def do_databases_backup( path )
    puts "doing databases backup"
    
    FileUtils.mkdir_p( File.dirname( path ) )
    tmp_sql_file_path = File.join( Dir::tmpdir, "#{File.basename( path, '.tar.gz' )}" )
    database_pass = (@opts[:database_pass].nil? || @opts[:database_pass]=='') ? '' : "-p#{@opts[:database_pass]}"
    Utils::command( "#{@opts[:mysqldump_path]} -u#{@opts[:database_user]} #{database_pass} --databases #{@opts[:databases].join(' ')} > #{tmp_sql_file_path}" )
    Utils::command( "#{@opts[:tar_path]} -cz --same-permissions --file #{path} --directory #{File.dirname(tmp_sql_file_path)} #{File.basename(tmp_sql_file_path)}" )
  end
  
  def clear
    puts "cleaning"
    
    [:yearly, :monthly, :weekly, :daily].each do |block|
      Dir.glob( "#{@opts[:path]}/files/*.#{block.to_s}.*" ).sort[0..(-1*(@opts[block]+1))].each do |file_path|
        File.delete( file_path )
      end
      
      Dir.glob( "#{@opts[:path]}/databases/*.#{block.to_s}.*" ).sort[0..(-1*(@opts[block]+1))].each do |file_path|
        File.delete( file_path )
      end      
    end
  end

  
  def run
    do_backup( @opts[:includes], @opts[:excludes], @opts[:databases], @opts[:database_user], @opts[:database_pass], @opts[:tar_path], @opts[:mysqldump_path], @opts[:path] )
    clear( @opts[:yearly], @opts[:monthly], @opts[:weekly], @opts[:daily], @opts[:path] )
  end
  
  

end


