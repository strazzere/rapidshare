
require 'rubygems'
require 'test/unit'

require 'shoulda'
require 'turn'
require 'fakeweb'
require 'mocha'

require 'rapidshare'

class Test::Unit::TestCase

  # don't allow internet connections for testing (we should use fixtures, except
  # integration testing)
  FakeWeb.allow_net_connect = false

  def read_fixture(filename, extension = 'txt')
    # add extension to file unless it already has it
    filename += ".#{extension}" unless (filename =~ /\.\w+$/)
    
    File.read File.expand_path(File.dirname(__FILE__) + "/fixtures/#{filename}")
  end

  # general setup, can be overriden or extended in specific tests
  #
  def setup
    @cookie = 'F0EEB41B38363A41F0D125102637DB7236468731F8DB760DC57934B4714C8D13'    

    # mock http requests for login into Rapidshare
    #
    FakeWeb.register_uri(:get,
      'https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=getaccountdetails&login=valid_login&password=valid_password&withcookie=1&cookie=',
      :body => read_fixture('getaccountdetails_valid.txt')
    )

    FakeWeb.register_uri(:get,
      "https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=getaccountdetails&withcookie=1&cookie=#{@cookie}",
      :body => read_fixture('getaccountdetails_valid.txt')
    )

    @rs = Rapidshare::Account.new('valid_login','valid_password')    
  end

end
