require 'test_helper'

class ApiTest < Test::Unit::TestCase

  def setup
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

  context "Checkfiles method" do
    setup do
      FakeWeb.register_uri(:get,
        "https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=checkfiles&files=829628035&filenames=HornyRhinos.jpg&cookie=#{@cookie}",
        :body => read_fixture('checkfiles_single.txt')
      )

      FakeWeb.register_uri(:get,
        "https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=checkfiles&files=829628035%2C428232373%2C766059293&filenames=HornyRhinos.jpg%2CHappyHippos.jpg%2CElegantElephants.jpg&cookie=#{@cookie}",
        :body => read_fixture('checkfiles_multi.txt')
      )

      FakeWeb.register_uri(:get,
        "https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=checkfiles&files=&filenames=&cookie=#{@cookie}",
        :body => 'ERROR: Files invalid. (1dd3841d)'
      )

      FakeWeb.register_uri(:get,
        "https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=checkfiles&filenames=file&files=server&cookie=#{@cookie}",
        :body => 'ERROR: Files invalid. (1dd3841d)'
      )

      @files = %w{
        https://rapidshare.com/files/829628035/HornyRhinos.jpg
        https://rapidshare.com/files/428232373/HappyHippos.jpg
        https://rapidshare.com/files/766059293/ElegantElephants.jpg
      }
    end
    
    should "return information about file" do
      file_info = @rs.api.checkfiles(@files.first)
      assert_instance_of Array, file_info 
      assert_equal 1, file_info.size
      assert_equal :ok, file_info.first[:file_status]
      assert_equal file_info.first,
        {:file_id=>"829628035", :file_name=>"HornyRhinos.jpg",
        :file_size=>"272288", :server_id=>"370", :file_status=>:ok,
        :short_host=>"l33", :md5=>"8700146036606454677EFAFB4A2AC52E"}
    end

    should "accept single file or array" do
      assert_equal 3, @rs.api.checkfiles(@files).size
      assert_equal 3, @rs.api.checkfiles(@files[0], @files[1], @files[2]).size
      assert_equal 1, @rs.api.checkfiles(@files.first).size
    end
    
    should "raise error if called without file parameters" do
      assert_raise(Rapidshare::API::Error) { @rs.api.checkfiles }
      assert_raise(Rapidshare::API::Error) { @rs.api.checkfiles('') }
    end

    should "raise error if called with obviously invalid files" do
      assert_raise(Rapidshare::API::Error) { @rs.api.checkfiles('http://server/file') }
    end
  end  

  context "Invalid method call" do
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

  context "text_to_hash method" do
    should "convert text in specific format to hash" do
      assert_equal @rs.api.text_to_hash(" key1=value1 \n\tkey2=value2"),
        { :key1 => 'value1', :key2 => 'value2' }
    end

    should "convert rapidshare text response to hash" do
      assert_equal @rs.api.text_to_hash(read_fixture('getaccountdetails_valid.txt')),
        {:accountid=>"12345", :servertime=>"1217244932", :addtime=>"127273393",
        :username=>"valid_account", :directstart=>"1", :country=>"CZ",
        :mailflags=>nil, :language=>nil, :jsconfig=>"1000",
        :email=>"valid_account@email.com", :curfiles=>"100",
        :curspace=>"103994340", :rapids=>"100", :billeduntil=>"1320093121",
        :nortuntil=>"1307123910",
        :cookie=>"F0EEB41B38363A41F0D125102637DB7236468731F8DB760DC57934B4714C8D13"}
    end
  end

end
