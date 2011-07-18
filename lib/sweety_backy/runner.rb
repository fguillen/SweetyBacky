require 'rubygems'
require 'fileutils'
require 'tmpdir'
require 'yaml'
require File.dirname(__FILE__) + "/utils.rb"

module SweetyBacky
  class Runner
    attr_reader :opts, :results
    
    def initialize( path = nil )
      if( !path.nil? )
        config( SweetyBacky::OptsReader.read_opts( path ) )
      end
      
      @results = []
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
        success     = nil
        backup_path = "#{@opts[:working_path]}/files/#{SweetyBacky::Utils.namerize( path )}.#{Date.today.strftime('%Y%m%d')}.#{SweetyBacky::Utils.period}.tar.gz"
        md5_path    = "#{backup_path}.md5"
        
        begin

          SweetyBacky::Commander.do_files_backup( path, backup_path )
          SweetyBacky::Commander.do_md5( backup_path, md5_path )
        
          if( @opts[:storage_system].to_sym == :s3 )
            upload_files_backup_to_s3( backup_path, md5_path )
          end
          
          success = true
          
        rescue Exception => e
          Utils.log( "ERROR: backing up file: '#{path}', e: #{e.message}" )
          Utils.log( e.backtrace.join("\n") )
          
          success = false
        end
        
        @results << { :name => "file: #{path}", :success => success }
      end
    end
    
    def do_databases_backup
      @opts[:databases].each do |database_name|
        
        success     = nil
        backup_path = "#{@opts[:working_path]}/databases/#{database_name}.#{Date.today.strftime('%Y%m%d')}.#{SweetyBacky::Utils.period}.sql.tar.gz"
        md5_path    = "#{backup_path}.md5"
        
        begin
          SweetyBacky::Commander.do_database_backup( database_name, backup_path, @opts)
          SweetyBacky::Commander.do_md5( backup_path, md5_path )
        
          if( @opts[:storage_system].to_sym == :s3 )
            upload_databases_backup_to_s3( backup_path, md5_path )
          end
          
          success = true
          
        rescue Exception => e
          Utils.log( "ERROR: backing up database: '#{database_name}', e: #{e.message}" )
          Utils.log( e.backtrace.join("\n") )
          
          success = false
        end
        
        @results << { :name => "database: #{database_name}", :success => success }
      end
    end
    

    
    def clean
      SweetyBacky::Commander.clean( @opts )
    end
    
    def print_results
      Utils.log( "RESULTS:" )
      Utils.log( "--------" )
      
      @results.each do |result|
        Utils.log( "#{result[:name]} -> #{result[:success] ? 'OK' : 'ERROR'}" )
      end
    end
    
    def run
      begin
        do_backup
        clean
        print_results
      rescue => e
        SweetyBacky::Utils.log "ERROR: #{e}"
        SweetyBacky::Utils.log "BACKTRACE: #{e.backtrace.join("\n")}"
        SweetyBacky::Utils.log "I should send and email at this moment"
      end
    end
  
    private
    
    def upload_databases_backup_to_s3( backup_path, md5_path )
      SweetyBacky::S3.upload(
        backup_path,
        "#{@opts[:s3_opts][:path]}/databases/#{File.basename( backup_path )}",
        @opts[:s3_opts]
      )
    
      SweetyBacky::S3.upload(
        backup_path,
        "#{@opts[:s3_opts][:path]}/databases/#{File.basename( md5_path )}",
        @opts[:s3_opts]
      )
    
      FileUtils.rm backup_path
      FileUtils.rm md5_path
    end
    
    def upload_files_backup_to_s3( backup_path, md5_path )
      SweetyBacky::S3.upload(
        backup_path,
        "#{@opts[:s3_opts][:path]}/files/#{File.basename( backup_path )}",
        @opts[:s3_opts]
      )
    
      SweetyBacky::S3.upload(
        md5_path,
        "#{@opts[:s3_opts][:path]}/files/#{File.basename( md5_path )}",
        @opts[:s3_opts]
      )
    
      FileUtils.rm backup_path
      FileUtils.rm md5_path
    end

  end
end

