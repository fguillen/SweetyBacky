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
      _tmp_sql_file_path = tmp_sql_file_path(backup_path)

      database_pass = opts[:database_pass].empty? ? '' : "-p'#{opts[:database_pass]}'"
      database_host = opts[:database_host].nil? ? '' : "-h#{opts[:database_host]}"
      database_port = opts[:database_port].nil? ? '' : "-P#{opts[:database_port]}"

      SweetyBacky::Utils::command( "mysqldump #{database_host} #{database_port} -u#{opts[:database_user]} #{database_pass} #{database_name} > #{_tmp_sql_file_path}" )
      SweetyBacky::Utils::command( "tar -cz --same-permissions --file #{backup_path} --directory #{File.dirname(_tmp_sql_file_path)} #{File.basename(_tmp_sql_file_path)}" )

      File.delete( _tmp_sql_file_path )
    end

    def self.tmp_sql_file_path(backup_path)
      File.join( Dir::tmpdir, "#{File.basename( backup_path, '.tar.gz' )}" )
    end

    def self.clean( opts )
      clean_files( opts )
      clean_databases( opts )
    end

    def self.clean_files( opts )
      SweetyBacky::Utils.log "cleaning files on #{opts[:target_path]}/files/"

      suffix = opts[:slices_size] ? ".part_*" : ""           # suffix support in case of spliting activate
      suffix_regex = opts[:slices_size] ? /\.part_.*/ : ""   # suffix support in case of spliting activate

      opts[:paths].each do |path|
        SweetyBacky::Utils.log "cleaning file #{path}"

        [:yearly, :monthly, :weekly, :daily].each do |period|
          paths_in(
            "#{opts[:target_path]}/files/#{SweetyBacky::Utils.namerize( path )}.*.#{period.to_s}.tar.gz#{suffix}",
            opts
          ).map do |file_name|
            file_name.match( "files\/#{SweetyBacky::Utils.namerize( path )}.(\\d{8}).#{period.to_s}.tar.gz#{suffix}" )[1]
          end.uniq.sort[0..(-1*(opts[period]+1))].each do |date_to_remove|
            paths_in(
              "#{opts[:target_path]}/files/#{SweetyBacky::Utils.namerize( path )}.#{date_to_remove}.#{period.to_s}.tar.gz#{suffix}",
              opts
            ).each do |file_path|
              Utils.log( "Removing file: #{file_path}" )
              remove_path( file_path, opts )
              remove_path( "#{file_path.gsub(suffix_regex, "")}.md5", opts ) if exists?( "#{file_path.gsub(suffix_regex, "")}.md5", opts )
            end
          end
        end
      end
    end

    def self.clean_databases( opts )
      SweetyBacky::Utils.log "cleaning databases on #{opts[:target_path]}/databases/"

      opts[:databases].each do |database_name|
        SweetyBacky::Utils.log "cleaning database #{database_name}"

        [:yearly, :monthly, :weekly, :daily].each do |period|
          paths_in(
            "#{opts[:target_path]}/databases/#{database_name}.*.#{period.to_s}.sql.tar.gz",
            opts
          ).sort[0..(-1*(opts[period]+1))].each do |file_path|
            remove_path( file_path, opts )
            remove_path( "#{file_path}.md5", opts ) if exists?( "#{file_path}.md5", opts )
          end
        end
      end
    end

    def self.exists?( path, opts )
      if( opts[:storage_system].to_sym == :s3 )
        return SweetyBacky::S3.exists?( path, opts[:s3_opts] )
      else
        return File.exists?( path )
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

    def self.do_slices( file_path, size )
      SweetyBacky::Utils::command( "split -b #{size}m #{file_path} #{file_path}.part_" )
      File.delete( file_path )
    end
  end
end
