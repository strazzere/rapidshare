require 'test_helper'

class RapidshareDownloadTest < Test::Unit::TestCase

  def setup
    url = 'https://rapidshare.com/files/829628035/HornyRhinos.jpg'
    api = nil

    @download = Rapidshare::Download.new(url, api)
  end

  context "new download instance" do

    should "extract fileid and filename from rapidshare link" do
      assert_equal '829628035', @download.fileid
      assert_equal 'HornyRhinos.jpg', @download.filename
    end

  end

  context "get_hostname method" do

    should_eventually "get server name from which the file can be downloaded" do
      assert_equal '', @download.get_hostname()
    end

  end

end
