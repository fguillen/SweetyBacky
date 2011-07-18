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
    
    s3 = ::S3::Service.new( SweetyBacky::S3.read_s3_password( @opts[:s3_opts][:passwd_file] ) )
    @bucket = s3.buckets.build( @opts[:s3_opts][:bucket] )
    @bucket.save
  end

  def teardown
    @bucket.destroy( true )
  end
  
  def test_do_backup_daily
    SweetyBacky::Utils.stubs( :period ).returns( 'daily' )
    
    @runner.do_backup
    
    assert( 
      @bucket.
        object( 
          "test/path/files/#{SweetyBacky::Utils.namerize( @opts[:paths][0] )}.#{Date.today.strftime('%Y%m%d')}.daily.tar.gz"
        ).exists? 
    )
    
    assert( 
      @bucket.
        object( 
          "test/path/databases/test.#{Date.today.strftime('%Y%m%d')}.daily.sql.tar.gz"
        ).exists? 
    )
    
    assert( 
      @bucket.
        object( 
          "test/path/files/#{SweetyBacky::Utils.namerize( @opts[:paths][0] )}.#{Date.today.strftime('%Y%m%d')}.daily.tar.gz.md5"
        ).exists? 
    )
    
    assert( 
      @bucket.
        object( 
          "test/path/databases/test.#{Date.today.strftime('%Y%m%d')}.daily.sql.tar.gz.md5"
        ).exists? 
    )
  end
    
end

