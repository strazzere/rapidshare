# encoding: utf-8

require "cgi"
# TODO replace with Net::HTTPS or Curb
require "httparty"

# Provides interface to RapidShare API.
#
# HTTPS requests are used by default, as recommended by RapidShare API
# documentation. If you want to use HTTP, you have to write complete URI in the
# API request, for example:
#
#   Rapidshare::API.get('https://api.rapidshare.com/cgi-bin/rsapi.cgi?sub=...')
#
class Rapidshare::API
  include HTTParty

  base_uri 'https://api.rapidshare.com'

  attr_reader :cookie

  ERROR_PREFIX = "ERROR: " unless defined?(ERROR_PREFIX)

  # Connects to Rapidshare API: logs in, retrieves cookie and account details.
  #
  # Params:
  # * *login* - premium account login
  # * *password* - premium account password
  #
  def initialize(login, password)
    params = { :login => login, :password => password, :withcookie => 1 }
    response = request(:getaccountdetails, params)
    data = text_to_hash(response)
    @cookie = data[:cookie]
  end

  def self.debug(debug)
    debug_output debug ? $stderr : false
  end

  # Calls specific RapidShare API service and returns result.
  #
  # Throws exception if error is received from RapidShare API.
  #
  # Params:
  # * *action* - service name, for example +checkfiles+
  # * *params* - hash of service parameters
  #
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

  # Provides instance interface to class method +request+.
  #
  def request(action, params = {})
    params.merge!(:cookie => cookie)
    self.class.request(action, params)
  end

  # Returns account details in hash.
  #
  def get_account_details
    params = { :withcookie => 1 }
    response = request(:getaccountdetails, params)
    text_to_hash(response)
  end

  # Retrieves information about RapidShare files.
  #
  # *Input:* array of files
  #
  # Examples: +checkfiles(file1)+, +checkfiles(file1,file2)+ or +checkfiles([file1,file2])+
  #
  # *Output:* array of hashes, which contain information about files
  # * *:file_id* (string) - part of url
  #
  #   Example: https://rapidshare.com/files/829628035/HornyRhinos.jpg -> +829628035+
  # * *:file_name* (string) - part of url
  #
  #   Example: https://rapidshare.com/files/829628035/HornyRhinos.jpg -> +HornyRhinos.jpg+
  # * *:file_size* (integer) - in bytes. returns 0 if files does not exists
  # * *:file_status* - decoded file status: +:ok+ or +:error+
  # * *:short_host* - used to construct download url
  # * *:server_id* - used to construct download url
  # * *:md5* 
  #
  def checkfiles(*urls)
    raise Rapidshare::API::Error if urls.empty?
    
    files, filenames = urls.flatten.map { |url| fileid_and_filename(url) }.transpose

    response = request(:checkfiles, :files => files.join(","), :filenames => filenames.join(","))
    
    response.strip.split(/\s*\n\s*/).map do |r|
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

  # Generates url path for Rapidshare request.
  #
  def self.build_path(action, params)
    "/cgi-bin/rsapi.cgi?sub=#{action}&#{params.to_query}"
  end

  # Convert file status code (returned by checkfiles method) to +:ok+ or +:error+ symbol.
  #
  def self.decode_file_status(status_code)
    # TODO in checkfiles, return both file_status as is and decoded file status
    # or just boolean value if file is OK and can be downloaded

    case status_code
      when 0 then :error # File not found
      when 1 then :ok # File OK
      when 3 then :error # Server down
      when 4 then :error # File marked as illegal
      else :error # uknown status, this shouldn't happen
    end
  end

  # Extracts file id and file name from Rapidshare url. Returns both in array.
  #
  # Example:
  #   https://rapidshare.com/files/829628035/HornyRhinos.jpg -> [ '829628035', 'HornyRhinos.jpg' ] 
  #
  def fileid_and_filename(url)
    url.split('/').slice(-2,2) || ['', '']
  end

  # Converts rapidshare response (which is just a text in specific format) to hash.
  #
  # Example:
  #   "key1=value1\nkey1=value2" -> { :key1 => 'value1', :key2 => 'value2' }
  #
  def text_to_hash(response)
    Hash[ response.strip.split(/\s*\n\s*/).map { |param| param.split('=') } ].symbolize_keys
  end

end
