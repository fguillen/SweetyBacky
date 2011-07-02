module SweetyBacky
  class Utils
    
    def self.period
      return 'yearly'   if( is_last_day_of_year? )
      return 'monthly'  if( is_last_day_of_month? )
      return 'weekly'   if( is_last_day_of_week? )
      return 'daily'
    end
    
    def self.is_last_day_of_year?
      return Date.new(Date.today.year, 12, -1) == Date.today
    end
    
    def self.is_last_day_of_month?
      return Date.new(Date.today.year, Date.today.month, -1) == Date.today
    end
  
    def self.is_last_day_of_week?
      return Date.today.cwday == 7
    end
  
    def self.command( _command )
      Utils.log "command: #{_command}"
      
      result = %x( #{_command} 2>&1 )
    
      raise "ERROR: on command: '#{_command}', result: '#{result}'"  if $?.exitstatus != 0
    
      return result
    end
  
    def self.log( msg )
      puts "#{Time.now.strftime("%Y-%m-%d %H:%M")}: #{msg}"
    end
    
    def self.namerize( path )
      path.gsub('/', '.').gsub(/^\./, '')
    end
    
    def self.read_opts( conf_path )
      SweetyBacky::Utils::log "conf_path: #{conf_path}"

      opts = YAML.load( File.read( conf_path ) )
      
      # symbolize keys
      opts.keys.each do |key|
        opts[key.to_sym] = opts.delete(key)
      end

      SweetyBacky::Utils::log "configuration:"
      SweetyBacky::Utils::log "------------"
      opts.each_pair do |key, value|
        SweetyBacky::Utils::log "#{key}: #{(value.instance_of? Array) ? value.join(' | ') : value}"
      end

      # TODO: test all options are ok

      return opts
    end
  end
end