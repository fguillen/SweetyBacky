module SweetyBacky
  module Commander    
    def self.do_files_backup( path, backup_path )
      SweetyBacky::Utils.log "doing files backup of #{path} to #{backup_path}"
    
      FileUtils.mkdir_p( File.dirname( backup_path ) )
      SweetyBacky::Utils::command( "tar -cz --directory #{path} --same-permissions --file #{backup_path} ." )
    end
  
    def self.do_database_backup( database_name, backup_path, opts )
      SweetyBacky::Utils.log "doing database backup #{database_name} on #{backup_path}"
    
      FileUtils.mkdir_p( File.dirname( backup_path ) )
      tmp_sql_file_path = File.join( Dir::tmpdir, "#{File.basename( backup_path, '.tar.gz' )}" )
      
      database_pass = opts[:database_pass].empty? ? '' : "-p'#{opts[:database_pass]}'"

      SweetyBacky::Utils::command( "mysqldump -u#{opts[:database_user]} #{database_pass} #{database_name} > #{tmp_sql_file_path}" )
      SweetyBacky::Utils::command( "tar -cz --same-permissions --file #{backup_path} --directory #{File.dirname(tmp_sql_file_path)} #{File.basename(tmp_sql_file_path)}" )
      
      File.delete( tmp_sql_file_path )
    end

    def self.clean( opts )
      clean_files( opts )
      clean_databases( opts )
    end
  
    def self.clean_files( opts )
      SweetyBacky::Utils.log "cleaning files on #{opts[:working_path]}/files/"
      
      opts[:paths].each do |path|
        SweetyBacky::Utils.log "cleaning file #{path}"
        
        [:yearly, :monthly, :weekly, :daily].each do |period|
          paths_in( 
            "#{opts[:working_path]}/files/#{SweetyBacky::Utils.namerize( path )}.*.#{period.to_s}.tar.gz",
            opts
          ).sort[0..(-1*(opts[period]+1))].each do |file_path|
            remove_path( file_path, opts )
          end      
        end
      end
    end
    
    def self.clean_databases( opts )
      SweetyBacky::Utils.log "cleaning databases on #{opts[:working_path]}/databases/"
      
      opts[:databases].each do |database_name|
        SweetyBacky::Utils.log "cleaning database #{database_name}"
        
        [:yearly, :monthly, :weekly, :daily].each do |period|
          paths_in( 
            "#{opts[:working_path]}/databases/#{database_name}.*.#{period.to_s}.sql.tar.gz",
            opts
          ).sort[0..(-1*(opts[period]+1))].each do |file_path|
            remove_path( file_path, opts )
          end      
        end
      end
    end
    
    def self.paths_in( path, opts )
      if( opts[:storage_system].to_sym == :s3 )
        return SweetyBacky::S3.paths_in( path, opts[:s3_opts] )
      else
        return Dir.glob( path )
      end
    end
    
    def self.remove_path( path, opts )
      if( opts[:storage_system].to_sym == :s3 )
        SweetyBacky::Utils.log "cleaning: removing #{opts[:s3_opts][:bucket]}/#{path}"
        SweetyBacky::S3.delete( path, opts[:s3_opts] )
      else
        SweetyBacky::Utils.log "cleaning: removing #{path}"
        File.delete( path )
      end
    end
    
    def self.do_md5( path, md5_path )
      digest = Digest::MD5.new();
      
      File.open( path, 'r' ) do |f|
        f.each_line { |line| digest << line }
      end

      result = digest.hexdigest
      
      File.open( md5_path, 'w' ) { |f| f.write result }
      
      return result
    end
  end
end