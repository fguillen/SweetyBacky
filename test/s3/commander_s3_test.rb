require "#{File.dirname(__FILE__)}/../test_helper"

class CommanderS3Test < Test::Unit::TestCase
  
  def setup
    SweetyBacky::Utils.stubs(:log)

    @opts = {
      :paths        => [ 'name1', 'name2' ],
      :databases    => [ 'name1', 'name2' ],
      :yearly       => 1,
      :monthly      => 2,
      :weekly       => 3,
      :daily        => 4,
      :storage_system => :s3,
      :s3_opts => {
        :bucket       => 'sweety_backy_test',
        :path         => 'test/path',
        :passwd_file  => '~/.s3.passwd'
      },
      :working_path => @tmp_dir
    }
    
    s3 = ::S3::Service.new( SweetyBacky::S3.read_s3_password( @opts[:s3_opts][:passwd_file] ) )
        
    @bucket = s3.buckets.build( @opts[:s3_opts][:bucket] )
    @bucket.save
  end

  def teardown
    @bucket.destroy( true )
  end

  def test_clear    
    [
      'name1.20081231.yearly',
      'name1.20081232.yearly',
      'name2.20091231.yearly',
      'name1.20100131.monthly',
      'name1.20100228.monthly',
      'name1.20100331.monthly',
      'name2.20100430.monthly',
      'name2.20100531.monthly',
      'name2.20100630.monthly',
      'name1.20100704.weekly',
      'name1.20100711.weekly',
      'name1.20100718.weekly',
      'name1.20100725.weekly',
      'name1.20100720.daily',
      'name2.20100721.daily',
      'name2.20100722.daily',
      'name2.20100723.daily',
      'name2.20100724.daily',
      'name2.20100726.daily'
    ].each do |file_part|
      SweetyBacky::S3.upload( "#{FIXTURES_PATH}/file.txt", "#{@opts[:s3_opts][:path]}/files/#{file_part}.tar.gz", @opts[:s3_opts] )
      SweetyBacky::S3.upload( "#{FIXTURES_PATH}/file.txt", "#{@opts[:s3_opts][:path]}/databases/#{file_part}.sql.tar.gz", @opts[:s3_opts] )
    end
    
    SweetyBacky::Commander.clear( @opts )
    
    files_keeped = SweetyBacky::S3.paths_in( "#{@opts[:s3_opts][:path]}/files/*", @opts[:s3_opts] ).join( "\n" )
    databases_keeped = SweetyBacky::S3.paths_in( "#{@opts[:s3_opts][:path]}/databases/*", @opts[:s3_opts] ).join( "\n" )
    
    # files to keep
    [
      'name1.20081232.yearly',
      'name2.20091231.yearly',
      'name1.20100228.monthly',
      'name1.20100331.monthly',
      'name2.20100531.monthly',
      'name2.20100630.monthly',
      'name1.20100718.weekly',
      'name1.20100725.weekly',
      'name1.20100720.daily',
      'name2.20100722.daily',
      'name2.20100723.daily',
      'name2.20100724.daily',
      'name2.20100726.daily'
    ].each do |file_part|
      assert_match( "#{file_part}.tar.gz", files_keeped )
      assert_match( "#{file_part}.sql.tar.gz", databases_keeped )
    end
    
    # files to deleted
    [
      'name1.20081231.yearly',
      'name1.20100131.monthly',
      'name2.20100430.monthly',
      'name1.20100704.weekly',
      'name2.20100721.daily'
    ].each do |file_part|
      assert_no_match( /#{file_part}.tar.gz/, files_keeped )
      assert_no_match( /#{file_part}.sql.tar.gz/, databases_keeped )
    end
  end

    
end

