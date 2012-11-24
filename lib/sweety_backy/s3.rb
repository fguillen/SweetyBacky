module SweetyBacky
  class S3
    def self.upload( path, s3_path, opts )
      SweetyBacky::Utils.log( "S3 uploading: #{path} to #{opts[:bucket]}/#{s3_path}" )

      s3 = AWS::S3.new( read_s3_password( opts[:passwd_file] ) )
      bucket = s3.buckets[ opts[:bucket] ]

      if !bucket.exists?
        bucket = s3.buckets.create( opts[:bucket] )
      end

      object = bucket.objects[ s3_path ]
      object.write( :file => path )
    end

    def self.object( path, opts )
      s3 = AWS::S3.new( read_s3_password( opts[:passwd_file] ) )
      bucket = s3.buckets[ opts[:bucket] ]
      object = bucket.objects[ path ]

      object
    end

    def self.exists?( path, opts )
      return object( path, opts ).exists?
    end

    def self.paths_in( path, opts )
      s3 = AWS::S3.new( read_s3_password( opts[:passwd_file] ) )
      bucket = s3.buckets[ opts[:bucket] ]

      regex = Regexp.escape( path ).gsub('\*', '.*').gsub('\?', '.')

      objects = bucket.objects.select { |e| e.key =~ /^#{regex}$/ }
      paths   = objects.map(&:key)

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
      SweetyBacky::S3.object( path, opts ).delete
    end

  end
end