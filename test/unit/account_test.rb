require 'test_helper'

class AccountTest < Test::Unit::TestCase

  # override default setup method with account login, it's tested it separately in this class
  def setup; end

  context "Invalid account login" do
    setup do
      FakeWeb.register_uri(:get,
        'https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=getaccountdetails&login=my_login&password=my_password&withcookie=1&cookie=',
        :body => 'ERROR: Login failed. Password incorrect or account not found. (221a75e5)'
      )
    end

    should "raise LoginFailed error" do
      assert_raise Rapidshare::API::Error::LoginFailed do
        Rapidshare::Account.new('my_login','my_password')
      end
    end    
  end

  context "Valid account" do
    setup do
      @cookie = 'F0EEB41B38363A41F0D125102637DB7236468731F8DB760DC57934B4714C8D13'
      
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

    context "login" do
      should "return valid username" do
        assert_equal 'valid_account', @rs.data[:username]
      end    
  
      should "return cookie" do
        assert_equal @cookie, @rs.data[:cookie]
      end
    end

    should "provide interface to RapidShare API" do
      assert_instance_of Rapidshare::API, @rs.api
      assert_equal @cookie, @rs.api.cookie
    end

    context "reload! method" do
      should "reload Rapidshare account data" do
        # PS: get_account_details method is tested in api_test
        @rs.api.expects(:get_account_details)
        @rs.reload!
      end
    end

    context "download method" do
      should "download file through Download class" do
        # PS: downloading is tested in integration tests
        Rapidshare::Download.any_instance.expects(:perform)
        @rs.download('https://rapidshare.com/files/829628035/HornyRhinos.jpg')
      end
    end
  
  end

end
