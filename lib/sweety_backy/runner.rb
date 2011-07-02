require 'rubygems'
require 'fileutils'
require 'tmpdir'
require 'yaml'
require File.dirname(__FILE__) + "/utils.rb"

module SweetyBacky
  class Runner
    attr_reader :opts
    
    def initialize( path = nil )
      if( !path.nil? )
        config( SweetyBacky::Utils.read_opts( path ) )
      end
    end
  
    def config( opts )
      @opts = {
        :paths          => [],
        :databases      => [],
        :yearly         => 1,
        :monthly        => 1,
        :weekly         => 2,
        :daily          => 4,
        :tar_path       => '/usr/bin/tar',
        :mysqldump_path => '/usr/bin/mysqldump'
      }.merge( opts )
    end
    
    def do_backup
      do_files_backup
      do_databases_backup
    end
    
    def do_files_backup
      @opts[:paths].each do |path|
        backup_path = "#{@opts[:backup_path]}/files/#{SweetyBacky::Utils.namerize( path )}.#{Date.today.strftime('%Y%m%d')}.#{SweetyBacky::Utils.period}.tar.gz"
        SweetyBacky::Commander.do_files_backup( path, backup_path, @opts )
      end
    end
    
    def do_databases_backup
      @opts[:databases].each do |database_name|
        backup_path = "#{@opts[:backup_path]}/databases/#{database_name}.#{Date.today.strftime('%Y%m%d')}.#{SweetyBacky::Utils.period}.sql.tar.gz"
        SweetyBacky::Commander.do_database_backup( database_name, backup_path, @opts)
      end
    end
    
    def run
      begin
        do_backup
        SweetyBacky::Commander.clear( @opts )
      rescue => e
        SweetyBacky::Utils.log "ERROR: #{e}"
        SweetyBacky::Utils.log "I should send and email at this moment"
      end
    end
  

  end
end

