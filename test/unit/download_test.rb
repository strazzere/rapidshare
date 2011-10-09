require 'test_helper'

class DownloadTest < Test::Unit::TestCase

  # extend general setup mehtod
  def setup
    super
    
    @file = 'https://rapidshare.com/files/829628035/HornyRhinos.jpg'
    @downloader = Rapidshare::Download.new(@file, @rs.api)
  end
  
  context "initialize method" do
    should "enable overriding filename attribute" do
      @downloader = Rapidshare::Download.new(@file, @rs.api, :save_as => 'picture_of_rhinos.jpg')
      assert_equal 'picture_of_rhinos.jpg', @downloader.filename
    end

    should "enable overriding downloads_dir attribute" do
      @downloader = Rapidshare::Download.new(@file, @rs.api, :downloads_dir => '/tmp')
      assert_equal '/tmp', @downloader.downloads_dir
    end
  end
    
  context "check method for valid file" do
    setup do
      @check_result = @downloader.check
    end
    
    should "return true" do
      assert @check_result
    end
    
    # test if check method assigns all attributes needed for download
    
    should "assign fileid attribute" do
      assert_equal '829628035', @downloader.fileid
    end

    should "assign filename attribute" do
      assert_equal 'HornyRhinos.jpg', @downloader.filename
    end

    should "assign filesize attribute" do
      assert_instance_of Float, @downloader.filesize
      assert_equal 272288.0, @downloader.filesize
    end

    should "assign server_id attribute" do
      assert_equal '370', @downloader.server_id
    end

    should "assign short_host attribute" do
      assert_equal 'l33', @downloader.short_host
    end
  end

  context "check method for invalid file" do
    setup do
      @downloader = Rapidshare::Download.new('', @rs.api)
      @check_result = @downloader.check
    end
    
    should "return false" do
      assert ! @check_result
    end

    should "return error" do
      assert ! @downloader.error.to_s.empty?
    end
  end

  # perform method for valid files, which actually downloads file from
  # Rapidshare, has been moved to integration tests
  
  context "perfom method for invalid file" do
    setup do
      @downloader = Rapidshare::Download.new('', @rs.api)
      @downloader.perform
    end

    should "not download anything" do
      assert ! @downloader.downloaded
    end

    should "return error" do
      assert ! @downloader.error.to_s.empty?
    end
  end

  context "download_link method" do
    should "return link which downloads file by Rapidshare API" do
      assert_equal @downloader.download_link,
        'https://rs.rapidshare.com/cgi-bin/rsapi.cgi?cookie=F0EEB41B38363A41F0D125102637DB7236468731F8DB760DC57934B4714C8D13&fileid=&filename=&sub=download'
    end
  end
  
  context "downloaded? method" do
    should "have the same value as \"downloaded\" attribute" do
      assert_equal @downloader.downloaded, @downloader.downloaded?
    end

    should "return \"false\" by default " do
      assert ! @downloader.downloaded?
    end

    should_eventually "return \"true\" after file was successfully downloaded" do
      assert true
    end
  end

end
