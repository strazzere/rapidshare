require File.dirname(__FILE__) + '/../test_helper'

class RapidshareApiTest < Test::Unit::TestCase
  
  context "Valid API request" do

    should "return response" do
      response = Rapidshare::API.request(:checkfiles, {
        :files => "439727873",
        :filenames => "DT-02-DT.rar"
      })
      assert response.is_a?(String)
      assert response.length > 0
      assert !response.include?("ERROR: ")
    end

  end
    
  context "API request with invalid login data" do

    should "raise LoginFailed error" do      
      assert_raise Rapidshare::API::Error::LoginFailed do
        Rapidshare::API.request(:getaccountdetails, {:login => "fake_user", :password => "pass", :type => "prem"})
      end
    end

  end        

  context "API request calling invalid routine" do

    should "raise InvalidRoutine error" do      
      assert_raise Rapidshare::API::Error::InvalidRoutineCalled do
        Rapidshare::API.request(:invalid_routine, {:param_1 => "value_1"})
      end
    end

  end

end
