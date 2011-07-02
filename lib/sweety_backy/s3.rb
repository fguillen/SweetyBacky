module SweetyBacky
  class S3
    def self.upload( path, backup_path, opts )
      SweetyBacky::Utils.log( "S3 uploading: #{path} to #{opts[:bucket]}/#{backup_path}" )
      
      s3 = ::S3::Service.new( read_s3_password( opts[:passwd_file] ) )
      bucket = s3.bucket( opts[:bucket] )
      
      if !bucket.exists?
        bucket = s3.buckets.build( opts[:bucket] )
        bucket.save
      end

      object = bucket.objects.build( backup_path )
      object.content = File.open( path )
      object.save
    end
    
    def self.object( path, opts )
      s3 = ::S3::Service.new( read_s3_password( opts[:passwd_file] ) )
      bucket = s3.buckets.find( opts[:bucket] )
      object = bucket.objects.find( path )
      
      return object
    end
    
    def self.paths_in( path, opts )
      s3 = ::S3::Service.new( read_s3_password( opts[:passwd_file] ) )
      bucket = s3.buckets.find( opts[:bucket] )
      
      regex = Regexp.escape( path ).gsub('\*', '.*').gsub('\?', '.')
      
      objects = bucket.objects.select { |e| e.key =~ /#{regex}/ }
      paths = objects.map(&:key)
      
      return paths
    end
    
    def self.read_s3_password( path )
      opts = YAML.load( File.read( File.expand_path path ) )
      new_opts = {}
      
      # symbolize keys
      opts.keys.each do |key|
        new_opts[key.to_sym] = opts[key]
      end
      
      return new_opts
    end
    
    def self.delete( path, opts )
      SweetyBacky::S3.object( path, opts ).destroy
    end
    
  end
end