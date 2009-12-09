require "progressbar"

class Rapidshare::Download

  attr_reader :cookie, :link, :remote_file, :status, :file_size, :save_as

  def initialize(link, cookie, save_as = nil)
    @cookie = cookie
    @progress = 0    
    retrieve_data_and_prepare_download(link, save_as)
  end
    
  def start
    return unless cookie
    uri = URI.parse(remote_file)
    host, path = [uri.host, uri.path]
    
    http = Net::HTTP.new(host)
    
    http.request_get(path, headers) do |response|
      bar = ::ProgressBar.new(save_as, file_size)
      File.open(save_as,'w') do |file|
        response.read_body do |segment|
          file.write(segment)
          @progress += segment.length
          bar.set(@progress)
        end
      end
    end 
  end
  
  protected
  
  def cookie_string
    return unless cookie
    "enc=#{cookie}; domain=.rapidshare.com; path=/; expires=Wed, 13-Nov-2024 15:00:00 GMT"
  end
  
  def headers
    cookie ? {'Cookie' => cookie_string} : {}
  end
  
  def retrieve_data_and_prepare_download(link, save_as)
    d = Rapidshare::API.check_files(link).first  
    @status = d[:file_status]
    if status == :ok  
      @remote_file = Rapidshare.build_file_url(d[:server_id], d[:short_host], d[:file_id], d[:file_name])
      @file_size = d[:file_size].to_i
      
      if save_as
        @save_as = save_as
      else
        @save_as = d[:file_name]
      end
    end
  end
  
end
