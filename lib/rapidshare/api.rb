require "httparty"

class Rapidshare::API
  
  include HTTParty
  base_uri 'api.rapidshare.com'

  API_VERSION = 1 unless defined?(API_VERSION)
  
  def self.request(action, params = {})
    path = self.build_path(action, params)
    response = self.get(path)
    if response.start_with?("ERROR: ")
      raise Rapidshare::API::Error.new(response)
    end
    response
  end
  
  def self.get_api_cpu
    action = "getapicpu"
    response = self.request(action)
    data = response.split(",")
    {:current => data[0], :max => data[1]}
  end
  
  def self.get_account_details_with_cookie(cookie)
    action = "getaccountdetails"    
    params = { :cookie => cookie, :withcookie => 1, :withrefstring => 1 }    
    response = self.request(action, params)
    self.parse_account_details(response)
  end
  
  def self.get_account_details(login, password, type)
    action = "getaccountdetails"    
    params = { :login => login, :password => password, :type => type, :withcookie => 1, :withrefstring => 1 }    
    response = self.request(action, params)
    self.parse_account_details(response)
  end
  
  def self.get_referrer_logs(login, password, type)
    action = "getreferrerlogs"
    params = { :login => login, :password => password, :type => type }  
    response = self.request(action, params)
    response
  end
  
  def self.get_point_logs(login, password, type)
    action = "getpointlogs"
    params = { :login => login, :password => password, :type => type }  
    response = self.request(action, params)
    response
  end  
  
  def self.list_real_folders(login, password, type)
    action = "listrealfolders"
    params = { :login => login, :password => password, :type => type }  
    response = self.request(action, params)
    response
  end  
  
  def self.premiumzone_logs(login, password)
    action = "premiumzonelogs"
    params = { :login => login, :password => password }  
    response = self.request(action, params)
    response
  end
    
  def self.check_files(url)
    action = "checkfiles"    
    url, file_id, file_name = url.match(Rapidshare::FILE_REGEXP).to_a    
    params = { :files => file_id, :filenames => file_name }
    response = self.request(action, params)    
    response.split("\n").map do |r|
      data = r.split(",")
      puts data.inspect
      {
        :file_id => data[0],
        :file_name => data[1],
        :file_size => data[2],
        :server_id => data[3],
        :file_status => self.decode_file_status(data[4].to_i),
        :short_host => data[5],
        :md5 => data[6]        
      }
    end
 
  end
  
  protected
  
  def self.build_path(action, params)
    action =  "#{action}_v#{API_VERSION}"
    "/cgi-bin/rsapi.cgi?sub=#{action}&#{self.to_query(params)}"
  end
  
  def self.to_query(params)
    require 'cgi' unless defined?(CGI) && defined?(CGI::escape)
    params.map do |k,v|
      "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
    end.join("&")
  end
  
  def self.decode_file_status(status_code)
    case status_code
      when 0 : :error # File not found
      when 1 : :ok # Anonymous downloading
      when 2 : :ok # TrafficShare direct download without any logging
      when 3 : :error # Server Down
      when 4 : :error # File marked as illegal
      when 5 : :error # Anonymous file locked, because it has more than 10 downloads already
      when 6 : :ok # TrafficShare direct download with enabled logging. Read our privacy policy to see what is logged.
      else
        :unknown # uknown status
      end
  end
  
  def self.parse_account_details(response)
    data = {}
    response.split("\n").each do |item|
      k, v = item.split("=")
      data[k] = v
    end
    data
  end

end
