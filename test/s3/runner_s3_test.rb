require "#{File.dirname(__FILE__)}/../test_helper"

class RunnerS3Test < Test::Unit::TestCase
  
  def setup
    SweetyBacky::Utils.stubs(:log)
    
    # runner
    @opts = {
      :paths          => [ "#{FIXTURES_PATH}/path" ],
      :databases      => [ "test" ],
      :yearly         => 1,
      :monthly        => 1,
      :weekly         => 2,
      :daily          => 4,
      :database_user  => 'test',
      :database_pass  => '',
      :storage_system => :s3,
      :s3_opts => {
        :bucket             => 'sweety_backy_test',
        :passwd_file        => '~/.s3.passwd',
        :path               => 'test/path'
      }
    }
    
    @runner = SweetyBacky::Runner.new
    @runner.config( @opts )
    
    s3 = AWS::S3.new( SweetyBacky::S3.read_s3_password( @opts[:s3_opts][:passwd_file] ) )
    @bucket = s3.buckets.create( @opts[:s3_opts][:bucket] )
  end

  def teardown
    @bucket.delete!
  end
  
  def test_do_backup_daily
    SweetyBacky::Utils.stubs( :period ).returns( 'daily' )
    
    @runner.do_backup
    
    assert( 
      @bucket.
        objects[ 
          "test/path/files/#{SweetyBacky::Utils.namerize( @opts[:paths][0] )}.#{Date.today.strftime('%Y%m%d')}.daily.tar.gz"
        ].exists? 
    )
    
    assert( 
      @bucket.
        objects[ 
          "test/path/databases/test.#{Date.today.strftime('%Y%m%d')}.daily.sql.tar.gz"
        ].exists? 
    )
    
    assert( 
      @bucket.
        objects[ 
          "test/path/files/#{SweetyBacky::Utils.namerize( @opts[:paths][0] )}.#{Date.today.strftime('%Y%m%d')}.daily.tar.gz.md5"
        ].exists? 
    )
    
    assert( 
      @bucket.
        objects[ 
          "test/path/databases/test.#{Date.today.strftime('%Y%m%d')}.daily.sql.tar.gz.md5"
        ].exists? 
    )
  end
  
  def test_initialize_with_config_file
    SweetyBacky::OptsReader.expects( :read_opts ).with( '/path/config.yml' ).returns( 
      { 
        :paths => [ 'pepe', 'juan' ],
        :storage_system => :s3,
        :s3_opts => {
          :path => '/s3/path'
        }
      }
    )
    
    runner = SweetyBacky::Runner.new( "/path/config.yml" )
    
    assert_equal( [ "pepe", "juan" ], runner.opts[:paths] )
    assert_equal( [], runner.opts[:databases] )
    assert_equal( 1, runner.opts[:yearly] )
    assert_equal( 1, runner.opts[:monthly] )
    assert_equal( 2, runner.opts[:weekly] )
    assert_equal( 4, runner.opts[:daily] )
    assert_equal( :s3, runner.opts[:storage_system] )
    assert_equal( '/s3/path', runner.opts[:s3_opts][:path] )
    assert_equal( '/s3/path', runner.opts[:target_path] )
  end
    
end

