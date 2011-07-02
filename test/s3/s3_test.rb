require "#{File.dirname(__FILE__)}/../test_helper"


class S3Test < Test::Unit::TestCase
  def setup
    SweetyBacky::Utils.stubs(:log)

    @opts = {
      :bucket             => 'sweety_backy_test',
      :path               => 'test_path',
      :passwd_file        => '~/.s3.passwd'
    }
    
    s3 = ::S3::Service.new( SweetyBacky::S3.read_s3_password( @opts[:passwd_file] ) )
    @bucket = s3.buckets.build( @opts[:bucket] )
    @bucket.save
  end
  
  def teardown
    @bucket.destroy( true )
  end
  
  def test_upload
    SweetyBacky::S3.upload(
      "#{FIXTURES_PATH}/file.txt",
      "test/path/file.txt",
      @opts
    )
    
    assert_equal(
      File.read( "#{FIXTURES_PATH}/file.txt" ),
      SweetyBacky::S3.object( "test/path/file.txt", @opts ).content
    )
  end
  
  def test_paths_in
    SweetyBacky::S3.upload( "#{FIXTURES_PATH}/file.txt", "test/path/file1.txt", @opts )
    SweetyBacky::S3.upload( "#{FIXTURES_PATH}/file.txt", "test/path/file2.txt", @opts )
    SweetyBacky::S3.upload( "#{FIXTURES_PATH}/file.txt", "test/path/file3.txt", @opts )
    SweetyBacky::S3.upload( "#{FIXTURES_PATH}/file.txt", "test/path/other_file.txt", @opts )
    
    paths = SweetyBacky::S3.paths_in( "test/path/file*.txt", @opts )
    
    assert_equal(3, paths.size)
    assert( ( paths.include? "test/path/file1.txt" ) )
    assert( ( paths.include? "test/path/file2.txt" ) )
    assert( ( paths.include? "test/path/file3.txt" ) )
    assert( ( !paths.include? "test/path/other_file.txt" ) )
  end
  
  def test_delete
    SweetyBacky::S3.upload( "#{FIXTURES_PATH}/file.txt", "test/path/file1.txt", @opts )
    SweetyBacky::S3.upload( "#{FIXTURES_PATH}/file.txt", "test/path/file2.txt", @opts )
    
    SweetyBacky::S3.delete( "test/path/file2.txt", @opts )
    
    assert( @bucket.object( "test/path/file1.txt" ).exists? )
    assert( !@bucket.object( "test/path/file2.txt" ).exists? )
  end
  
end