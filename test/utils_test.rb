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
  
end