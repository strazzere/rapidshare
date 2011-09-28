require 'test_helper'

class AccountTest < Test::Unit::TestCase

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

end
