module SweetyBacky
  module OptsReader
    def self.read_opts( conf_path )
      SweetyBacky::Utils::log "conf_path: #{conf_path}"

      opts = YAML.load( File.read( conf_path ) )
      new_opts = {}
      
      # symbolize keys
      opts.keys.each do |key|        
        
        if( opts[key].is_a? Hash )
          new_opts[key.to_sym] = {}
          opts[key].keys.each do |key2|
            new_opts[key.to_sym][key2.to_sym] = opts[key][key2]
          end
        else
          new_opts[key.to_sym] = opts[key]
        end

      end
      
      log_configuration( new_opts )

      # TODO: test all options are ok

      return new_opts
    end
        
    def self.log_configuration( opts )
      SweetyBacky::Utils::log "configuration:"
      SweetyBacky::Utils::log "------------"
      opts.each_pair do |key, value|
        if( value.is_a? Array )
          SweetyBacky::Utils::log "#{key}: #{value.join(' | ')}"
        elsif( value.is_a? Hash )
          value.each_pair do |key2, value2|
            SweetyBacky::Utils::log "#{key} => #{key2}: #{value2}"
          end
        else
          SweetyBacky::Utils::log "#{key}: #{value}"
        end
      end
    end
    
  end
end