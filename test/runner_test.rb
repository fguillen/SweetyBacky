require "#{File.dirname(__FILE__)}/test_helper"

class RunnerTest < Test::Unit::TestCase
  
  def setup
    SweetyBacky::Utils.stubs(:log)
    
    # tmp dir
    @tmp_dir = File.join( Dir::tmpdir, "sweety_backy_#{Time.now.to_i}" )
    Dir.mkdir( @tmp_dir )
    
    # runner
    @opts = {
      :paths          => [ "#{FIXTURES_PATH}/path" ],
      :databases      => [ "test" ],
      :yearly         => 1,
      :monthly        => 1,
      :weekly         => 2,
      :daily          => 4,
      :backup_path    => @tmp_dir,
      :database_user  => 'test',
      :database_pass  => ''
    }
    
    @runner = SweetyBacky::Runner.new
    @runner.config( @opts )
  end
  
  def teardown
    FileUtils.rm_rf @tmp_dir  if File.exists?(@tmp_dir)
  end
  
  def test_do_backup_yearly
    Delorean.time_travel_to( '2009-12-31' ) do
      @runner.do_backup
    end
    
    assert( File.exists?( "#{@tmp_dir}/files/#{SweetyBacky::Utils.namerize( @opts[:paths][0] )}.20091231.yearly.tar.gz") )
    assert( File.exists?( "#{@tmp_dir}/databases/test.20091231.yearly.sql.tar.gz") )
  end
  
  def test_do_backup_monthly    
    Delorean.time_travel_to( '2010-01-31' ) do
      @runner.do_backup
    end

    assert( File.exists?( "#{@tmp_dir}/files/#{SweetyBacky::Utils.namerize( @opts[:paths][0] )}.20100131.monthly.tar.gz") )
    assert( File.exists?( "#{@tmp_dir}/databases/test.20100131.monthly.sql.tar.gz") )
  end
  
  def test_do_backup_weekly    
    Delorean.time_travel_to( '2010-01-03' ) do
      @runner.do_backup
    end
    
    assert( File.exists?( "#{@tmp_dir}/files/#{SweetyBacky::Utils.namerize( @opts[:paths][0] )}.20100103.weekly.tar.gz") )
    assert( File.exists?( "#{@tmp_dir}/databases/test.20100103.weekly.sql.tar.gz") )
  end
  
  def test_do_backup_daily
    Delorean.time_travel_to( '2010-01-04' ) do
      @runner.do_backup
    end
    
    assert( File.exists?( "#{@tmp_dir}/files/#{SweetyBacky::Utils.namerize( @opts[:paths][0] )}.20100104.daily.tar.gz") )
    assert( File.exists?( "#{@tmp_dir}/databases/test.20100104.daily.sql.tar.gz") )
  end

  def test_run
    @runner.expects(:do_backup)
    SweetyBacky::Commander.expects(:clear)
    
    @runner.run
  end
  
  def test_initialize_with_config_file
    runner = SweetyBacky::Runner.new( "#{FIXTURES_PATH}/config.yml" )
    
    assert_equal( [ "path1", "path2" ], runner.opts[:paths] )
    assert_equal( [ "db1", "db2" ], runner.opts[:databases] )
    assert_equal( 1, runner.opts[:yearly] )
    assert_equal( 2, runner.opts[:monthly] )
    assert_equal( 3, runner.opts[:weekly] )
    assert_equal( 4, runner.opts[:daily] )
    assert_equal( '/backup_path', runner.opts[:backup_path] )
    assert_equal( 'database_user', runner.opts[:database_user] )
    assert_equal( 'database_pass', runner.opts[:database_pass] )
  end
    
end

