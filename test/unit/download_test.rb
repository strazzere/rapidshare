require 'test_helper'

class DownloadTest < Test::Unit::TestCase

  # extend general setup mehtod
  def setup
    super
    
    @file = 'https://rapidshare.com/files/829628035/HornyRhinos.jpg'
    @downloader = Rapidshare::Download.new(@file, @rs.api)
  end
  
  # TODO how to test "perform" method? probably by integration testing

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

    should_eventually  "return \"true\" after file was successfully downloaded" do
      assert true
    end
  end

end
