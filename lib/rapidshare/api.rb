require "cgi"
require "httparty"

class Rapidshare::API
  include HTTParty
  #
  # According to RapidShare API docs it's recommended to use https
  #
  # PS: although this is easy to override, just write complete uri in request:
  # Rapidshare::API.get('https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=...')
  #
  base_uri 'https://api.rapidshare.com'
  attr_reader :cookie

  ERROR_PREFIX = "ERROR: " unless defined?(ERROR_PREFIX)

  def initialize(login, password)
    params = { :login => login, :password => password, :withcookie => 1 }
    response = request(:getaccountdetails, params)
    data = text_to_hash(response)
    @cookie = data[:cookie]
  end

  def self.debug(debug)
    debug_output debug ? $stderr : false
  end

  def self.request(action, params = {})
    path = self.build_path(action, params)
    
    response = self.get(path)
    if response.start_with?(ERROR_PREFIX)
      case error = response.sub(ERROR_PREFIX, "").split('.').first
        when "Login failed"
          raise Rapidshare::API::Error::LoginFailed
        when "Invalid routine called"
          raise Rapidshare::API::Error::InvalidRoutineCalled.new(action)
        else
          raise Rapidshare::API::Error.new(error)
        end
    end
    response
  end

  def request(action, params = {})
    params.merge!(:cookie => cookie)
    self.class.request(action, params)
  end

  def get_account_details
    params = { :withcookie => 1 }
    response = request(:getaccountdetails, params)
    text_to_hash(response)
  end

  # get status details about files
  # input - array of files: checkfiles(file1), checkfiles(file1, file2),
  #   checkfiles([file1,file2])
  # output params (hash returned for each file):
  # :file_id (string) - part of url
  #   https://rapidshare.com/files/829628035/HornyRhinos.jpg -> '829628035'
  # :file_name (string) - part of url
  #   https://rapidshare.com/files/829628035/HornyRhinos.jpg -> 'HornyRhinos.jpg'
  # :file_size (integer) - in bytes. returns 0 if files does not exists
  # :file_status - decoded file status: :ok or :error,
  # :short_host - used to construct download url
  # :server_id - used to construct download url
  # :md5 
  #
  def checkfiles(*urls)
    urls.flatten!
    files = []
    filenames = []
    urls.each do |u|
      url, file, filename = u.match(Rapidshare::FILE_REGEXP).to_a
      files << file
      filenames << filename
    end

    params = { :files => files.join(","), :filenames => filenames.join(",") }
    response = request(:checkfiles, params)
    
    response.split("\n").map do |r|
      data = r.split(",")
      {
        :file_id => data[0],
        :file_name => data[1],
        :file_size => data[2],
        :server_id => data[3],
        :file_status => self.class.decode_file_status(data[4].to_i),
        :short_host => data[5],
        :md5 => data[6]
      }
    end
  end

  alias check_files checkfiles

  def self.build_path(action, params)
    "/cgi-bin/rsapi.cgi?sub=#{action}&#{self.to_query(params)}"
  end

  def self.to_query(params)
      params.map do |k,v|
      "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
    end.join("&")
  end

  # TODO in checkfiles, return both file_status as is and decoded file status
  # or just boolean value if file is OK and can be downloaded
  #
  def self.decode_file_status(status_code)
    case status_code
      when 0 then :error # File not found
      when 1 then :ok # File OK
      when 3 then :error # Server down
      when 4 then :error # File marked as illegal
      else :error # uknown status, this shouldn't happen
    end
  end

  # convert rapidshare response (just a text in specific format, see example) to hash
  # example: key1=value1\nkey1=value2 => { :key1 => 'value1', :key2 => 'value2' }
  #
  def text_to_hash(response)
    Hash[ response.strip.split(/\s*\n\s*/).map { |param| param.split('=') } ].symbolize_keys
  end

end
