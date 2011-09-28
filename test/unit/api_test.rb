require 'test_helper'

class ApiTest < Test::Unit::TestCase

  # TODO move to checkfiles test
  # 
  context "Valid API request" do
    setup do
      FakeWeb.register_uri(:get,
        'https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=checkfiles&files=439727873&filenames=DT-02-DT.rar',
        :body => '439727873,DT-02-DT.rar,94615872,971,1,l3,F50F440C343749FD7C91286369BED105'
      )
    end
    
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

  context "Invalid routine call" do
    setup do
      FakeWeb.register_uri(:get,
        'https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=invalid_routine&param_1=value_1',
        :body => 'ERROR: Invalid routine called. (5b97895d)'
      )
    end

    should "raise InvalidRoutine error" do
      assert_raise Rapidshare::API::Error::InvalidRoutineCalled do
        Rapidshare::API.request(:invalid_routine, {:param_1 => "value_1"})
      end
    end
  end

end
