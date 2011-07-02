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
        config( SweetyBacky::OptsReader.read_opts( path ) )
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
        :storage_system => :local
      }.merge( opts )
      
      if( @opts[:storage_system].to_sym == :s3 )
        @opts[:working_path] = File.join( Dir::tmpdir, "sweety_backy_#{Time.now.to_i}" )
      else
        @opts[:working_path] = @opts[:local_opts][:path]
      end
    end
    
    def do_backup
      do_files_backup
      do_databases_backup
    end
    
    def do_files_backup
      @opts[:paths].each do |path|
        backup_path = "#{@opts[:working_path]}/files/#{SweetyBacky::Utils.namerize( path )}.#{Date.today.strftime('%Y%m%d')}.#{SweetyBacky::Utils.period}.tar.gz"
        SweetyBacky::Commander.do_files_backup( path, backup_path, @opts )
        
        if( @opts[:storage_system].to_sym == :s3 )
          SweetyBacky::S3.upload(
            backup_path,
            "#{@opts[:s3_opts][:path]}/files/#{File.basename( backup_path )}",
            @opts[:s3_opts]
          )
          
          FileUtils.rm_rf backup_path
        end
      end
    end
    
    def do_databases_backup
      @opts[:databases].each do |database_name|
        backup_path = "#{@opts[:working_path]}/databases/#{database_name}.#{Date.today.strftime('%Y%m%d')}.#{SweetyBacky::Utils.period}.sql.tar.gz"
        SweetyBacky::Commander.do_database_backup( database_name, backup_path, @opts)
        
        if( @opts[:storage_system].to_sym == :s3 )
          SweetyBacky::S3.upload(
            backup_path,
            "#{@opts[:s3_opts][:path]}/databases/#{File.basename( backup_path )}",
            @opts[:s3_opts]
          )
          
          FileUtils.rm_rf backup_path
        end
      end
    end
    
    def run
      begin
        do_backup
        SweetyBacky::Commander.clear( @opts )
      rescue => e
        SweetyBacky::Utils.log "ERROR: #{e}"
        SweetyBacky::Utils.log "BACKTRACE: #{e.backtrace.join("\n")}"
        SweetyBacky::Utils.log "I should send and email at this moment"
      end
    end
  

  end
end

