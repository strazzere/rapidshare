require "cgi"
require "httparty"

class Rapidshare::API

  include HTTParty
  base_uri 'api.rapidshare.com'
  attr_reader :cookie

  API_VERSION = "v1" unless defined?(API_VERSION)
  ERROR_PREFIX = "ERROR: " unless defined?(ERROR_PREFIX)
  UNIMPLEMENTED = %w(check_incomplete rename_file move_files_to_real_folder rename_real_folder delete_files add_real_folder del_real_folder move_real_folder list_files list_real_folders set_account_details enable_rs_antihack disable_rs_antihack send_rs_antihackmail file_migrator new_link_list edit_link_list get_link_list copy_files_to_link_list new_link_list_subfolder delete_link_list delete_link_list_entries edit_link_list_entry traffic_share_type mass_poll traffic_share_logs traffic_share_bandwidth buy_lots send_mail get_reward set_reward ppointst_of_points)
  
  def initialize(login, password, type)
    params = { :login => login, :password => password, :type => type, :withcookie => 1 }    
    response = request(:getaccountdetails, params)
    data = to_hash(response)
    @cookie = data[:cookie]
  end
  
  def self.request(action, params = {})
    versioned_action = self.version_action(action)
    path = self.build_path(versioned_action, params)
    puts path
    response = self.get(path)
    if response.start_with?(ERROR_PREFIX)
      case error = response.sub(ERROR_PREFIX, "")
        when "Login failed."
          raise Rapidshare::API::Error::LoginFailed
        when "Type invalid."
          raise Rapidshare::API::Error::TypeInvalid
        when "Invalid routine called."
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

  def get_api_cpu
    request(:getapicpu).split(",").each(&:to_i)
  end
  
  def next_upload_server
    request(:nextuploadserver).to_i
  end
  
  def get_account_details
    params = { :withcookie => 1, :withrefstring => 1 }    
    response = request(:getaccountdetails, params)
    to_hash(response)
  end
  
  def list_real_folders
    request(:listrealfolders)
  end  
  
  def get_referrer_logs
    request(:getreferrerlogs)
  end
  
  def get_point_logs
    request(:getpointlogs)
  end  
  
  def premiumzone_logs
    request(:premiumzonelogs)
  end
  
  def rename_file
    raise
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
  
  def self.version_action(action)
    "#{action}_#{API_VERSION}"
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
