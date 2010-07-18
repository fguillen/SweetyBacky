require 'rubygems'
require 'fileutils'
require 'tmpdir'
require File.dirname(__FILE__) + "/utils.rb"

class SweetyBacky
  def do_backup( includes, excludes, databases, database_user, database_pass, folder_path )
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
    path = "#{folder_path}/files/#{Date.today.strftime('%Y%m%d')}.#{block}.tar.gz"
    self.do_files_backup( includes, excludes, path )
    
    # databases
    path = "#{folder_path}/databases/#{Date.today.strftime('%Y%m%d')}.#{block}.sql.tar.gz"
    self.do_databases_backup( databases, database_user, database_pass, path )
  end
  
  def do_files_backup( includes, excludes, path )
    puts "doing files backup"
    
    FileUtils.mkdir_p( File.dirname( path ) )
    exclude_file_path = File.join( Dir::tmpdir, "#{Time.now.to_i}_exclude.txt" )
    File.open( exclude_file_path, 'w' ) { |f| f.write excludes.join("\n") }
    Utils::command( "tar -cz --same-permissions --file #{path} --exclude-from #{exclude_file_path} #{includes.join(' ')}" )
  end
  
  def do_databases_backup( databases, database_user, database_pass, path )
    puts "doing databases backup"
    
    FileUtils.mkdir_p( File.dirname( path ) )
    tmp_sql_file_path = File.join( Dir::tmpdir, "#{File.basename( path, '.tar.gz' )}" )
    database_pass = (database_pass=='') ? '' : "-p#{database_pass}"
    Utils::command( "/opt/mysql/bin/mysqldump -u#{database_user} #{database_pass} --databases #{databases.join(' ')} > #{tmp_sql_file_path}" )
    Utils::command( "tar -cz --same-permissions --file #{path} --directory #{File.dirname(tmp_sql_file_path)} #{File.basename(tmp_sql_file_path)}" )
  end
  
  def clear( yearly, monthly, weekly, daily, path )
    puts "cleaning"
    
    opts = {:yearly => yearly, :monthly => monthly, :weekly => weekly, :daily => daily}
    
    opts.keys.each do |block|
      Dir.glob( "#{path}/files/*.#{block.to_s}.*" ).sort[0..(-1*(opts[block]+1))].each do |file_path|
        File.delete( file_path )
      end
      
      Dir.glob( "#{path}/databases/*.#{block.to_s}.*" ).sort[0..(-1*(opts[block]+1))].each do |file_path|
        File.delete( file_path )
      end      
    end
  end

  
  def run( conf_path )
    opts = Utils::read_opts( conf_path )
    puts "configuration: #{opts.inspect}"
  
    do_backup( opts['includes'], opts['excludes'], opts['databases'], opts['database_user'], opts['database_pass'], opts['path'] )
    clear( opts['yearly'], opts['monthly'], opts['weekly'], opts['daily'], opts['path'] )
  end
  
  

end


