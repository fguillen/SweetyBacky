require_relative "test_helper"

class OptsReaderTest < Minitest::Test
  def setup
    SweetyBacky::Utils.stubs(:log)
  end

  def test_read_opts
    opts = SweetyBacky::OptsReader.read_opts( "#{FIXTURES_PATH}/config_s3.yml" )

    assert_equal( [ "path1", "path2" ], opts[:paths] )
    assert_equal( [ "db1", "db2" ], opts[:databases] )
    assert_equal( 1, opts[:yearly] )
    assert_equal( 2, opts[:monthly] )
    assert_equal( 3, opts[:weekly] )
    assert_equal( 4, opts[:daily] )
    assert_equal( 'database_user', opts[:database_user] )
    assert_equal( 'database_pass', opts[:database_pass] )
    assert_equal( 'bucket_name', opts[:s3_opts][:bucket] )
    assert_equal( 's3/path/path', opts[:s3_opts][:path] )
    assert_equal( '/path/.s3.passwd', opts[:s3_opts][:passwd_file] )
  end


end
