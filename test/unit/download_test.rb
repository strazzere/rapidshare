require 'test_helper'

class DownloadTest < Test::Unit::TestCase

  # extend general setup mehtod
  def setup
    super
    
    @file = 'https://rapidshare.com/files/829628035/HornyRhinos.jpg'
    @downloader = Rapidshare::Download.new(@file, @rs.api)
  end

end
