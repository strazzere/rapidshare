require 'test_helper'

# In order to run this test, you have to set up YAML configuration file ".rapidshare"
# in home directory with your login and password to premium account.
#
# Example:
# :login: 'your_login'
# :password: 'your_password'
#
# PS: fakeweb won't work for this anyway, it seems to ingore curb

class DownloadTest < Test::Unit::TestCase

  @@downloads_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tmp'))
  @@filename = 'horny_rhinos.jpg'
  @@file_path = File.join(@@downloads_dir, @@filename)

  def setup
    FakeWeb.allow_net_connect = true

    Dir.mkdir(@@downloads_dir) unless File.exists?(@@downloads_dir)
    File.delete(@@file_path) if File.exists?(@@file_path)

    settings = YAML::load(File.read(File.join(ENV['HOME'],'.rapidshare'))) rescue {}
  
    @rs = Rapidshare::API.new(settings)

    @file = 'https://rapidshare.com/files/829628035/HornyRhinos.jpg'

    # PS: FakeWeb ignores Curb requests
    @downloader = @rs.download(@file,
      :downloads_dir => @@downloads_dir, :save_as => @@filename
    )   
  end
  
  def teardown
    File.delete(@@file_path) if File.exists?(@@file_path)
    if File.exists?(@@downloads_dir)
      Dir.rmdir(@@downloads_dir) rescue ''
    end
  end  

  context "perform method" do
    should "download file from Rapidshare" do
      assert @downloader.downloaded?
    # should "should save downloaded file to specific directory and path if set" do
      assert File.exists?(@@file_path)
    end
  end

end
