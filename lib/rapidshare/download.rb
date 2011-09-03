require 'curb'
require 'progressbar'

# PS: before downloading we have to check if file exists. Check_file methods
# also gives us information for the download: hostname, filesize for progressbar
#
class Rapidshare::Download
  DOWNLOAD_URL = 'https://rs%s%s.rapidshare.com/cgi-bin/rsapi.cgi?%s'

  attr_reader :url, :api, :fileid, :filename, :filesize, :server_id,
    :short_host, :downloads_dir, :downloaded, :error

  def initialize(url, api, options = {})
    @url = url
    @api = api
    @filename = options[:save_as]
    @downloads_dir = options[:downloads_dir] || Dir.pwd
 
    # OPTIMIZE replace these simple status variables with status codes
    # and corresponding errors like "File not found"
    # 
    # set to true when file is successfully downloaded
    @downloaded = false
    # non-critical error is stored here, beside being displayed
    @error = nil
  end

  def perform
    # step 1 - check file, checks if file exist and return its file size
    # TODO move to separate method
    response = @api.check_file(@url)
    if (response[:file_status] == :ok)
      @fileid = response[:file_id]
      @filename ||= response[:file_name]
      @filesize = response[:file_size].to_f
      @server_id = response[:server_id] 
      @short_host = response[:short_host] 
    else
      @error = "File not found"
      return self
    end
      
    # step 3 - actual download, downloads the file
    # TODO use ActiveSupport#to_query method for creating params string
    # TODO move download_url-generation to separate method
    download_params = { :sub => 'download', :fileid => @fileid, :filename => @filename, :cookie => @api.cookie }
    request = DOWNLOAD_URL % [ @server_id, @short_host, download_params.map { |k,v| "#{k}=#{v}" }.join('&') ]
    
    file = open(File.join(downloads_dir, filename), 'wb')

    bar = ProgressBar.new(@filename, @filesize)
    bar.file_transfer_mode

    Curl::Easy.perform(request) do |curl|
      curl.on_progress do |dl_total, dl_now|
        bar.set(dl_now)
        dl_now <= dl_total
      end 

      curl.on_body do |data|
        file << data
        data.length
      end
      
      curl.on_complete { bar.finish }
    end

    file.close
    
    @downloaded = true
    self
  end

end
