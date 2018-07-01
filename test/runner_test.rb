require_relative "test_helper"

class RunnerTest < Minitest::Test

  def setup
    SweetyBacky::Utils.stubs(:log)

    # tmp dir
    @tmp_dir = File.join( Dir::tmpdir, "sweety_backy_#{Time.now.to_i}" )
    Dir.mkdir( @tmp_dir )  unless File.exists?(@tmp_dir)

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
      :storage_system => :local,
      :local_opts     => {
        :path => @tmp_dir
      }
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

    assert( File.exists?( "#{@tmp_dir}/files/#{SweetyBacky::Utils.namerize( @opts[:paths][0] )}.20091231.yearly.tar.gz" ) )
    assert( File.exists?( "#{@tmp_dir}/databases/test.20091231.yearly.sql.tar.gz" ) )

    assert( File.exists?( "#{@tmp_dir}/files/#{SweetyBacky::Utils.namerize( @opts[:paths][0] )}.20091231.yearly.tar.gz.md5" ) )
    assert( File.exists?( "#{@tmp_dir}/databases/test.20091231.yearly.sql.tar.gz.md5" ) )
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
    @runner.expects(:print_results)
    SweetyBacky::Commander.expects(:clean)

    @runner.run
  end

  def test_initialize_with_config_file
    SweetyBacky::OptsReader.expects( :read_opts ).with( '/path/config.yml' ).returns(
      {
        :paths => [ 'pepe', 'juan' ],
        :local_opts => {
          :path => '/local/path'
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
    assert_equal( :local, runner.opts[:storage_system] )
    assert_equal( '/local/path', runner.opts[:local_opts][:path] )
    assert_equal( '/local/path', runner.opts[:working_path] )
    assert_equal( '/local/path', runner.opts[:target_path] )
  end

  def test_upload_files_backup_to_s3_with_slices
    @runner.opts[:slices_size] = 10
    @runner.opts[:s3_opts] = "s3_opts"

    sequence_uploads = sequence( "uploads" )
    sequence_removes = sequence( "removes" )

    SweetyBacky::S3.expects(:upload).with(
      "#{FIXTURES_PATH}/slices/file1.txt.part_aa",
      "#{@tmp_dir}/files/file1.txt.part_aa",
      @runner.opts[:s3_opts]
    ).in_sequence( sequence_uploads )


    SweetyBacky::S3.expects(:upload).with(
      "#{FIXTURES_PATH}/slices/file1.txt.part_ab",
      "#{@tmp_dir}/files/file1.txt.part_ab",
      @runner.opts[:s3_opts]
    ).in_sequence( sequence_uploads )

    SweetyBacky::S3.expects(:upload).with(
      "#{FIXTURES_PATH}/slices/file1.txt.md5",
      "#{@tmp_dir}/files/file1.txt.md5",
      @runner.opts[:s3_opts]
    ).in_sequence( sequence_uploads )

    FileUtils.expects(:rm).with("#{FIXTURES_PATH}/slices/file1.txt.part_aa").in_sequence( sequence_removes )
    FileUtils.expects(:rm).with("#{FIXTURES_PATH}/slices/file1.txt.part_ab").in_sequence( sequence_removes )
    FileUtils.expects(:rm).with("#{FIXTURES_PATH}/slices/file1.txt.md5").in_sequence( sequence_removes )

    @runner.upload_files_backup_to_s3(
      "#{FIXTURES_PATH}/slices/file1.txt",
      "#{FIXTURES_PATH}/slices/file1.txt.md5"
    )

    # FileUtils.expects(:rm).with()
  end

end

