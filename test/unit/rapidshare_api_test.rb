require File.dirname(__FILE__) + '/../test_helper'

class RapidshareApiTest < Test::Unit::TestCase

  # http://rapidshare.com/files/282385210/Digable_Planets_-_Blowout_Comb__1994_.zip

  
  context "API request" do
    
    context "when valid params" do
     
      should "return response" do
        response = Rapidshare::API.request(:checkfiles, {
          :files => "282385210",
          :filenames => "Digable_Planets_-_Blowout_Comb__1994_.zip"
        })
        assert response.is_a?(String)        
        assert response.length > 0
        assert !response.include?("ERROR: ")
      end
    
    end
    
    context "invalid params" do
    
      should "raise API Error" do
      
        assert_raise Rapidshare::API::Error::LoginFailed do
          Rapidshare::API.request(:getaccountdetails, {:login => "fake_user", :password => "pass", :type => "prem"})
        end
        
        assert_raise Rapidshare::API::Error::TypeInvalid do
          Rapidshare::API.request(:getaccountdetails, {:login => "user", :password => "pass", :type => "fake_type"})
        end
        
        assert_raise Rapidshare::API::Error::InvalidRoutineCalled do
          Rapidshare::API.request(:invalid_routine, {:param_1 => "value_1"})
        end      
      end
      
    end
    
    context "API methods" do    
      setup {@api = Rapidshare::API.new(ENV['RSLOGIN'], ENV['RSPASSWORD'], "prem")}
      should "raise error" do
        assert_raise RuntimeError do
          @api.rename_file
        end
      end

      
      # nextuploadserver_v1
      context "next_upload_server" do
        setup {@api = Rapidshare::API.new(ENV['RSLOGIN'], ENV['RSPASSWORD'], "prem")}
        should "return next upload server" do
          response =  @api.next_upload_server
          assert response.is_a?(Integer)
        end
      
      end

      # getapicpu_v1
      context "get_api_cpu" do
        setup {@api = Rapidshare::API.new(ENV['RSLOGIN'], ENV['RSPASSWORD'], "prem")}
        should "return current and maximum API calls usage" do
          response = @api.get_api_cpu
          assert response.is_a?(Array)
          assert_equal 2, response.size
        end
      end
    
    end


  end

end
