require 'test_helper'

class ApiTest < Test::Unit::TestCase

  context "calling invalid method" do
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

  context "initialize method" do
    setup do
      FakeWeb.register_uri(:get,
        'https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=getaccountdetails&cookie=&login=invalid_login&password=invalid_password&withcookie=1',
        :body => 'ERROR: Login failed. Password incorrect or account not found. (221a75e5)'
      )
      
      FakeWeb.register_uri(:get,
        'https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=getaccountdetails&cookie=invalid_cookie',
        :body => 'ERROR: Login failed. Login data invalid. (0320f9f0)'
      )      
    end
    
    should "have cookie" do
      @api = Rapidshare::API.new(:login => 'valid_login', :password => 'valid_password')
      assert_equal @cookie, @api.cookie
    end

    should "not require login if cookie is provided" do
      @api = Rapidshare::API.new(:cookie => @cookie)
      assert_equal @cookie, @api.cookie
    end

    should "raise LoginFailed exception for invalid login data" do
      assert_raise(Rapidshare::API::Error::LoginFailed) do
        Rapidshare::API.new(:login => 'invalid_login', :password => 'invalid_password')
      end
    end

    should "raise LoginFailed exception for invalid cookie" do
      assert_raise(Rapidshare::API::Error::LoginFailed) do
        Rapidshare::API.new(:cookie => 'invalid_cookie')
      end
    end

  end

  context "request method" do
    setup do
      FakeWeb.register_uri(:get,
        "https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=getrapidtranslogs&cookie=#{@cookie}",
        :body => read_fixture('getrapidtranslogs.txt')
      )
    end
    
    should "return response body as it is by default" do
      assert_equal @rs.request(:getrapidtranslogs), read_fixture('getrapidtranslogs.txt')
    end

    should "optionally parse response like CSV file" do
      response = @rs.request(:getrapidtranslogs, :parser => 'csv')
      assert_equal 5, response.size
      assert_equal response.last,
        ['1278352832', '0', '-4', 'Daily account billing (Events in July 2010)']
    end

    should "optionally parse response like key=value hash" do
      response = @rs.request(:getaccountdetails, :parser => 'hash')
      assert_instance_of Hash, response
      assert_equal response,
        {
          "rapids"=>"100",
          "curfiles"=>"100",
          "country"=>"CZ",
          "billeduntil"=>"1320093121",
          "jsconfig"=>"1000",
          "language"=>nil,
          "username"=>"valid_account",
          "nortuntil"=>"1307123910",
          "addtime"=>"127273393",
          "cookie"=>@cookie,
          "mailflags"=>nil,
          "directstart"=>"1",
          "servertime"=>"1217244932",
          "curspace"=>"103994340",
          "email"=>"valid_account@email.com",
          "accountid"=>"12345"
        }
    end
  end

  context "get_account_details method" do
    setup do
      @account_details = @rs.get_account_details
    end

    should "return account details in hash" do
      assert_instance_of Hash, @account_details
    end

    should "return corrent account details" do
      assert_equal @account_details, {
        :accountid=>"12345",
        :servertime=>"1217244932",
        :addtime=>"127273393",
        :username=>"valid_account",
        :directstart=>"1",
        :country=>"CZ",
        :mailflags=>nil,
        :language=>nil,
        :jsconfig=>"1000",
        :email=>"valid_account@email.com",
        :curfiles=>"100",
        :curspace=>"103994340",
        :rapids=>"100",
        :billeduntil=>"1320093121",
        :nortuntil=>"1307123910",
        :cookie=>@cookie
      }
    end
  end

  context "checkfiles method" do
    setup do
      FakeWeb.register_uri(:get,
        "https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=checkfiles&files=829628035&filenames=HornyRhinos.jpg&cookie=#{@cookie}",
        :body => read_fixture('checkfiles_single.txt')
      )

      FakeWeb.register_uri(:get,
        "https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=checkfiles&cookie=#{@cookie}&filenames=HornyRhinos.jpg%252CHappyHippos.jpg%252CElegantElephants.jpg&files=829628035%252C428232373%252C766059293",
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
      file_info = @rs.checkfiles(@files.first)
      assert_instance_of Array, file_info 
      assert_equal 1, file_info.size
      assert_equal :ok, file_info.first[:file_status]
      assert_equal file_info.first,
        {:file_id=>"829628035", :file_name=>"HornyRhinos.jpg",
        :file_size=>"272288", :server_id=>"370", :file_status=>:ok,
        :short_host=>"l33", :md5=>"8700146036606454677EFAFB4A2AC52E"}
    end

    should "accept single file or array" do
      assert_equal 3, @rs.checkfiles(@files).size
      assert_equal 3, @rs.checkfiles(@files[0], @files[1], @files[2]).size
      assert_equal 1, @rs.checkfiles(@files.first).size
    end
    
    should "raise error if called without file parameters" do
      assert_raise(Rapidshare::API::Error) { @rs.checkfiles }
      assert_raise(Rapidshare::API::Error) { @rs.checkfiles('') }
    end

    should "raise error if called with obviously invalid files" do
      assert_raise(Rapidshare::API::Error) { @rs.checkfiles('http://server/file') }
    end
  end  

  context "download method" do
    should "download file through Download class" do
      # PS: downloading is tested in integration tests
      Rapidshare::Download.any_instance.expects(:perform)
      @rs.download('https://rapidshare.com/files/829628035/HornyRhinos.jpg')
    end
  end

  # helper methods

  context "decode_file_status method" do
    should "return :ok symbol if RapidShare file can be downloaded" do
      assert_equal :ok, Rapidshare::API.decode_file_status(1)
    end

    should "return :error symbol if RapidShare file cannot be downloaded" do
      error_status_codes = [ 0, 2, 3, 4, 100 ]      
      assert_equal [:error], error_status_codes.map { |status_code| Rapidshare::API.decode_file_status(status_code) }.uniq
    end
  end

  context "fileid_and_filename method" do
    should "return file_id and file_name in array from valid rapidshare link" do
      assert_equal ['', ''], @rs.fileid_and_filename('')
    end

    should "return array of empty strings for invalid rapidshare link" do
      url = 'https://rapidshare.com/files/829628035/HornyRhinos.jpg'
      assert_instance_of Array, @rs.fileid_and_filename(url)
      assert_equal ['829628035', 'HornyRhinos.jpg'], @rs.fileid_and_filename(url)
    end
  end

  context "text_to_hash method" do
    should "convert text in specific format to hash" do
      assert_equal @rs.text_to_hash(" key1=value1 \n\tkey2=value2"),
        { :key1 => 'value1', :key2 => 'value2' }
    end

    should "convert rapidshare text response to hash" do
      assert_equal @rs.text_to_hash(read_fixture('getaccountdetails_valid.txt')),
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
