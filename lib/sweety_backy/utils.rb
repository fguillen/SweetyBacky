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
      
      result = %x( #{_command} )
    
      raise "ERROR: on command: '#{_command}', result: '#{result}'"  if $?.exitstatus != 0
    
      return result
    end
  
    def self.log( msg )
      puts "#{Time.now.strftime("%Y-%m-%d %H:%M")}: #{msg}"
    end
    
    def self.namerize( path )
      path.gsub('/', '.').gsub(/^\./, '')
    end
    
  end
end