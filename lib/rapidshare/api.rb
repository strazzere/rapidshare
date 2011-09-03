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
    data = to_hash(response)
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
    to_hash(response)
  end

  def check_files(urls)
    raise ArgumentError, "must be array of rapidshare links" unless urls.is_a?(Array)
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

  def check_file(url)
    check_files([url]).first
  end

  protected

  def self.build_path(action, params)
    "/cgi-bin/rsapi.cgi?sub=#{action}&#{self.to_query(params)}"
  end

  def self.to_query(params)
      params.map do |k,v|
      "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
    end.join("&")
  end

  def self.decode_file_status(status_code)
    case status_code
      when 0 then :error # File not found
      when 1 then :ok # Anonymous downloading
      when 2 then :ok # TrafficShare direct download without any logging
      when 3 then :error # Server Down
      when 4 then :error # File marked as illegal
      when 5 then :error # Anonymous file locked, because it has more than 10 downloads already
      when 6 then :ok # TrafficShare direct download with enabled logging. Read our privacy policy to see what is logged.
      else :unknown # uknown status
    end
  end

  def to_hash(response)
    data = {}
    response.split("\n").each do |item|
      k, v = item.split("=")
      data[k.to_sym] = v
    end
    data
  end

end
