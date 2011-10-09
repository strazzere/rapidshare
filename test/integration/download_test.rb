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

  def setup
    FakeWeb.allow_net_connect = true

    settings = YAML::load(File.read(File.join(ENV['HOME'],'.rapidshare'))) rescue nil
    
    @rs = Rapidshare::Account.new(settings[:login], settings[:password])

    @file = 'https://rapidshare.com/files/829628035/HornyRhinos.jpg'

    @downloader = Rapidshare::Download.new(@file, @rs.api)
  end
  
  def teardown    
    FakeWeb.allow_net_connect = false
  end
  
  context "perform method" do
    should "download the file from Rapidshare" do
      @downloader.perform
      assert @downloader.downloaded?
    end    
  end
  
  # TODO write more tests regarding downloaded file,
  # saving into specific dir under specific filename
  # and remove the file in teardown method

end
