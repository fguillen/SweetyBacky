class Utils
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
    # puts "command: #{_command}"
    %x( #{_command} )
  end
  
  def self.read_opts( conf_path )
    raw_config = File.read( conf_path )
    opts = YAML.load(raw_config)
    
    # TODO: test all options are ok
    
    return opts
  end
end