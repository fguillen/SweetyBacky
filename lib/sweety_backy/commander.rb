module SweetyBacky
  module Commander    
    def self.do_files_backup( path, backup_path, opts )
      SweetyBacky::Utils.log "doing files backup of #{path} to #{backup_path}"
    
      FileUtils.mkdir_p( File.dirname( backup_path ) )
      SweetyBacky::Utils::command( "tar -cz --directory #{path} --same-permissions --file #{backup_path} ." )
    end
  
    def self.do_database_backup( database_name, backup_path, opts )
      SweetyBacky::Utils.log "doing database backup #{database_name} on #{backup_path}"
    
      FileUtils.mkdir_p( File.dirname( backup_path ) )
      tmp_sql_file_path = File.join( Dir::tmpdir, "#{File.basename( backup_path, '.tar.gz' )}" )
      
      database_pass = opts[:database_pass].empty? ? '' : "-p#{opts[:database_pass]}"
      
      SweetyBacky::Utils::command( "mysqldump -u#{opts[:database_user]} #{opts[:database_pass]} #{database_name} > #{tmp_sql_file_path}" )
      SweetyBacky::Utils::command( "tar -cz --same-permissions --file #{backup_path} --directory #{File.dirname(tmp_sql_file_path)} #{File.basename(tmp_sql_file_path)}" )
      
      File.delete( tmp_sql_file_path )
    end

    def self.clear( opts )
      clear_files( opts )
      clear_databases( opts )
    end
  
    def self.clear_files( opts )
      SweetyBacky::Utils.log "cleaning files"
      
      opts[:paths].each do |path|
        SweetyBacky::Utils.log "cleaning file #{path}"
        
        [:yearly, :monthly, :weekly, :daily].each do |period|
          Dir.glob( "#{opts[:backup_path]}/files/#{SweetyBacky::Utils.namerize( path )}.*.#{period.to_s}.*" ).sort[0..(-1*(opts[period]+1))].each do |file_path|
            File.delete( file_path )
          end      
        end
      end
    end
    
    def self.clear_databases( opts )
      SweetyBacky::Utils.log "cleaning databases"
      
      opts[:databases].each do |database_name|
        SweetyBacky::Utils.log "cleaning database #{database_name}"
        
        [:yearly, :monthly, :weekly, :daily].each do |period|
          Dir.glob( "#{opts[:backup_path]}/databases/#{database_name}.*.#{period.to_s}.*" ).sort[0..(-1*(opts[period]+1))].each do |file_path|
            File.delete( file_path )
          end      
        end
      end
    end
    
  end
end