require 'curb'
require 'progressbar'

# this class downloads files from RapidShare
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

  # check if file exists and get data necessary for download
  # return true or false, which determines whether the file can be downloaded
  # 
  def check
    # PS: Api#checkfiles throws exception when file cannot be found
    response = @api.checkfiles(@url) rescue {}

    if (response[:file_status] == :ok)
      @fileid = response[:file_id]
      @filename ||= response[:file_name]
      @filesize = response[:file_size].to_f
      @server_id = response[:server_id] 
      @short_host = response[:short_host]
      true
    else
      # TODO report errors according to actual file status
      @error = "File not found"
      false
    end
  end

  # downloads the file
  #
  def perform
    # before downloading we have to check if file exists. checkfiles service
    # also gives us information for the download: hostname, file size for
    # progressbar
    return self unless self.check
    
    file = open(File.join(@downloads_dir, @filename), 'wb')

    bar = ProgressBar.new(@filename, @filesize)
    bar.file_transfer_mode

    Curl::Easy.perform(self.download_link) do |curl|
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

  # return link which downloads the file
  #
  def download_link
    download_params = { :sub => 'download', :fileid => @fileid, :filename => @filename, :cookie => @api.cookie }
    DOWNLOAD_URL % [ @server_id, @short_host, download_params.to_query ]
  end

  def downloaded?
    @downloaded
  end

end
