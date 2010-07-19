require 'rubygems'
require 'test/unit'
require 'mocha'
require 'delorean'
require File.dirname(__FILE__) + "/sweety_backy.rb"

class SweetyBackyTest < Test::Unit::TestCase
  
  def setup
    # Moching log
    Utils.stubs(:log)
    
    # tmp dir
    @tmp_dir = File.join( Dir::tmpdir, "sweety_backy_#{Time.now.to_i}" )
    Dir.mkdir( @tmp_dir )
    
    # prepare test folders
    Dir.mkdir( @tmp_dir + "/to_back/" )
    %w( a b c d ).each do |dir|
      Dir.mkdir( @tmp_dir + "/to_back/#{dir}" )
      File.open( @tmp_dir + "/to_back/#{dir}/wadus.txt", 'w' ) { |f| f.write 'wadus' }
    end
    File.open( @tmp_dir + "/to_back/a/exclude.txt", 'w' ) { |f| f.write 'wadus' }
    
    # configuration file
    File.open( File.dirname(__FILE__) + "/configuration.test.tmp.yml", 'w' ) do |f|
      f.write File.read( File.dirname(__FILE__) + "/configuration.test.yml" ).gsub( "#tmp_dir#", @tmp_dir )
    end    
    
    # SweetyBacky
    @sb = SweetyBacky.new( File.dirname(__FILE__) + "/configuration.test.tmp.yml" )
  end
  
  def teardown
    FileUtils.rm_rf @tmp_dir  if File.exists?(@tmp_dir)
    File.delete( File.dirname(__FILE__) + "/configuration.test.tmp.yml" )  if File.exists?( File.dirname(__FILE__) + "/configuration.test.tmp.yml" )
  end
  
  def test_do_files_backup
    @sb.do_files_backup( "#{@tmp_dir}/back.tar.gz" )
    
    result = %x(tar -tzvf #{@tmp_dir}/back.tar.gz)
    
    assert_match( "to_back/a/wadus.txt", result )
    assert_match( "to_back/d/wadus.txt", result )
    assert_no_match(/to_back\/b\/wadus.txt/, result ) 
    assert_no_match(/to_back\/c\/wadus.txt/, result )
    assert_no_match(/to_back\/a\/exclude.txt/, result )
  end
  
  def test_do_databases_backup
    @sb.do_databases_backup( "#{@tmp_dir}/back.sql.tar.gz" )
    
    result = %x(tar -tzvf #{@tmp_dir}/back.sql.tar.gz)
    assert_match( /\sback.sql$/, result )
  end
  
  def test_do_backup_yearly
    Delorean.time_travel_to( '2009-12-31' ) do
      @sb.do_backup
    end
    
    assert( File.exists?( "#{@tmp_dir}/files/20091231.yearly.tar.gz") )
    assert( File.exists?( "#{@tmp_dir}/databases/20091231.yearly.sql.tar.gz") )
  end
  
  def test_do_backup_monthly    
    Delorean.time_travel_to( '2010-01-31' ) do
      @sb.do_backup
    end
    
    assert( File.exists?( "#{@tmp_dir}/files/20100131.monthly.tar.gz") )
    assert( File.exists?( "#{@tmp_dir}/databases/20100131.monthly.sql.tar.gz") )
  end
  
  def test_do_backup_weekly    
    Delorean.time_travel_to( '2010-01-03' ) do
      @sb.do_backup
    end
    
    assert( File.exists?( "#{@tmp_dir}/files/20100103.weekly.tar.gz") )
    assert( File.exists?( "#{@tmp_dir}/databases/20100103.weekly.sql.tar.gz") )
  end
  
  def test_do_backup_daily
    Delorean.time_travel_to( '2010-01-04' ) do
      @sb.do_backup
    end
    
    assert( File.exists?( "#{@tmp_dir}/files/20100104.daily.tar.gz") )
    assert( File.exists?( "#{@tmp_dir}/databases/20100104.daily.sql.tar.gz") )
  end
  
  def test_clear
    Dir.mkdir( "#{@tmp_dir}/files" )  unless File.exists?( "#{@tmp_dir}/files" )
    Dir.mkdir( "#{@tmp_dir}/databases" )  unless File.exists?( "#{@tmp_dir}/databases" )
    
    [
      '20081231.yearly',
      '20091231.yearly',
      '20100131.monthly',
      '20100228.monthly',
      '20100331.monthly',
      '20100430.monthly',
      '20100531.monthly',
      '20100630.monthly',
      '20100704.weekly',
      '20100711.weekly',
      '20100718.weekly',
      '20100725.weekly',
      '20100720.daily',
      '20100721.daily',
      '20100722.daily',
      '20100723.daily',
      '20100724.daily',
      '20100726.daily'
    ].each do |file_part|
      File.open( "#{@tmp_dir}/files/#{file_part}.tar.gz", 'w' ) { |f| f.write 'wadus' }
      File.open( "#{@tmp_dir}/databases/#{file_part}.sql.tar.gz", 'w' ) { |f| f.write 'wadus' }
    end
    
    # puts @tmp_dir
    # exit 1
    
    @sb.clear
    
    files_keeped = Dir.glob( "#{@tmp_dir}/files/*" ).join( "\n" )
    databases_keeped = Dir.glob( "#{@tmp_dir}/databases/*" ).join( "\n" )
    
    # files to keep
    [
      '20091231.yearly',
      '20100331.monthly',
      '20100430.monthly',
      '20100531.monthly',
      '20100630.monthly',
      '20100718.weekly',
      '20100725.weekly',
      '20100721.daily',
      '20100722.daily',
      '20100723.daily',
      '20100724.daily',
      '20100726.daily'
    ].each do |file_part|
      assert_match( "#{file_part}.tar.gz", files_keeped )
      assert_match( "#{file_part}.sql.tar.gz", databases_keeped )
    end
    
    # files to deleted
    [
      '20081231.yearly',
      '20100131.monthly',
      '20100228.monthly',
      '20100704.weekly',
      '20100711.weekly',
      '20100720.daily'
    ].each do |file_part|
      assert_no_match( /#{file_part}.tar.gz/, files_keeped )
      assert_no_match( /#{file_part}.sql.tar.gz/, databases_keeped )
    end
  end
  
  def test_run
    @sb.expects(:do_backup)
    @sb.expects(:clear)
    @sb.run
  end
  
  def test_error_on_command
    assert_raise RuntimeError do
      Utils::command( 'command_not_exists' )
    end
  end

    
end

