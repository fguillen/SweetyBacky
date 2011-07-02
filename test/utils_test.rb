require "#{File.dirname(__FILE__)}/test_helper"

class UtilsTest < Test::Unit::TestCase
  def setup
    SweetyBacky::Utils.stubs(:log)
  end
  
  def test_error_on_command
    assert_raise RuntimeError do
      SweetyBacky::Utils::command( 'command_not_exists' )
    end
  end
  
  def test_namerize
    assert_equal( 
      'Users.fguillen.Develop.Ruby.SweetyBacky.test.fixtures.path', 
      SweetyBacky::Utils.namerize( '/Users/fguillen/Develop/Ruby/SweetyBacky/test/fixtures/path' ) 
    )
    
    assert_equal( 'path', SweetyBacky::Utils.namerize( '/path' ) )
    assert_equal( 'path', SweetyBacky::Utils.namerize( 'path' ) )
  end
  
  def test_read_opts
    opts = SweetyBacky::Utils.read_opts( "#{FIXTURES_PATH}/config.yml" )
    
    assert_equal( [ "path1", "path2" ], opts[:paths] )
    assert_equal( [ "db1", "db2" ], opts[:databases] )
    assert_equal( 1, opts[:yearly] )
    assert_equal( 2, opts[:monthly] )
    assert_equal( 3, opts[:weekly] )
    assert_equal( 4, opts[:daily] )
    assert_equal( '/backup_path', opts[:backup_path] )
    assert_equal( 'database_user', opts[:database_user] )
    assert_equal( 'database_pass', opts[:database_pass] )
  end
  
  
end