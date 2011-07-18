require "#{File.dirname(__FILE__)}/test_helper"

class CommanderTest < Test::Unit::TestCase
  
  def setup
    SweetyBacky::Utils.stubs(:log)
    
    # tmp dir
    @tmp_dir = File.join( Dir::tmpdir, "sweety_backy_#{Time.now.to_i}" )
    Dir.mkdir( @tmp_dir )  unless File.exists?(@tmp_dir)
  end
  
  def teardown
    FileUtils.rm_rf @tmp_dir  if File.exists?(@tmp_dir)
  end
  
  def test_do_files_backup
    SweetyBacky::Commander.do_files_backup( 
      "#{FIXTURES_PATH}/path", 
      "#{@tmp_dir}/back.tar.gz",
      {}
    )
    
    result = %x(tar -tzvf #{@tmp_dir}/back.tar.gz)

    assert_match( "./", result )
    assert_match( "./file1.txt", result )
    assert_match( "./a/", result )
    assert_match( "./b/file3.txt", result )
  end
  
  def test_do_databases_backup
    SweetyBacky::Commander.do_database_backup( 
      "test",  
      "#{@tmp_dir}/back.sql.tar.gz",
      {
        :database_user => "test", 
        :database_pass => ""
      }
    )
    
    result = %x(tar -tzvf #{@tmp_dir}/back.sql.tar.gz)
    
    assert_match( /\sback.sql$/, result )
  end

  
  def test_clean
    opts = {
      :paths        => [ 'name1', 'name2' ],
      :databases    => [ 'name1', 'name2' ],
      :yearly       => 1,
      :monthly      => 2,
      :weekly       => 3,
      :daily        => 4,
      :storage_system => :local,
      :local_opts => {
        :path => @tmp_dir
      },
      :working_path => @tmp_dir
    }
    
    Dir.mkdir( "#{@tmp_dir}/files" )  unless File.exists?( "#{@tmp_dir}/files" )
    Dir.mkdir( "#{@tmp_dir}/databases" )  unless File.exists?( "#{@tmp_dir}/databases" )
    
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
      File.open( "#{@tmp_dir}/files/#{file_part}.tar.gz", 'w' ) { |f| f.write 'wadus' }
      File.open( "#{@tmp_dir}/databases/#{file_part}.sql.tar.gz", 'w' ) { |f| f.write 'wadus' }
    end
    
    # puts @tmp_dir
    # exit 1
    
    SweetyBacky::Commander.clean( opts )
    
    files_keeped = Dir.glob( "#{@tmp_dir}/files/*" ).join( "\n" )
    databases_keeped = Dir.glob( "#{@tmp_dir}/databases/*" ).join( "\n" )
    
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

