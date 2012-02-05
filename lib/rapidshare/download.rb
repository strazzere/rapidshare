# encoding: utf-8

module Rapidshare
  
  # Downloads files from Rapidshare. Separate from +Rapidshare::API+ class because
  # downloading is much more complex than other service calls.
  #
  #
  class Download
    DOWNLOAD_URL = 'https://rs%s%s.rapidshare.com/cgi-bin/rsapi.cgi?%s'
  
    attr_reader :url, :api, :fileid, :filename, :filesize, :server_id,
      :short_host, :downloads_dir, :downloaded, :error

    # custom errors for Rapidshare::API class
    class Error < StandardError; end
    class Error::DownloadFailed < StandardError; end
  
    # Options:
    # * *filename* (optional) - specifies filename under which the file will be
    #   saved. Default: filename parsed from Rapidshare link.
    # * *downloads_dir* (optional) - specifies directory into which downloaded files
    #   will be saved. Default: current directory.
    #
    def initialize(url, api, options = {}, proxy = {})
      @url = url
      @api = api
      @filename = options[:save_as]
      @downloads_dir = options[:downloads_dir] || Dir.pwd
      @proxy = proxy

      # OPTIMIZE replace these simple status variables with status codes
      # and corresponding errors like "File not found"
      # 
      # set to true when file is successfully downloaded
      @downloaded = false
      # non-critical error is stored here, beside being displayed
      @error = nil
    end
  
    # Checks if file exists (using checkfiles service) and gets data necessary for download.
    #
    # Returns true or false, which determines whether the file can be downloaded.
    #
    def check
      # PS: Api#checkfiles throws exception when file cannot be found
      response = @api.checkfiles(@url).first rescue {}
      
      if (response[:file_status] == :ok)
        @fileid = response[:file_id]
        @filename ||= response[:file_name]
        @filesize = response[:file_size].to_f
        @server_id = response[:server_id] 
        @short_host = response[:short_host]
        @md5 = response[:md5]
        true
      else
        # TODO report errors according to actual file status
        @error = "File not found"
        false
      end
    end
  
    # Downloads file. Calls +check+ method first.
    #
    def perform
      return self unless self.check
      
      url = URI.parse(self.download_link)

      http = Net::HTTP.new(url.host, url.port, @proxy[:proxy_address], @proxy[:proxy_port], @proxy[:proxy_login], @proxy[:proxy_password])
      http.use_ssl = (url.scheme == 'https')
      body = http.get(URI::escape(url.request_uri)).body

      # TODO : Add unit test for this block
      if(Digest::MD5.hexdigest(body).casecmp(@md5))
        file = open(File.join(@downloads_dir, @filename), 'wb')
        file << body
        file.close
        @downloaded = true
      else
        @downloaded = false
        raise Error::DownloadFailed.new('MD5 of the file did not match the MD5 provided by Rapidshare!')
      end
      
      self
    end
  
    # Generates link which downloads file by Rapidshare API
    #
    def download_link
      download_params = { :sub => 'download', :fileid => @fileid, :filename => @filename, :cookie => @api.cookie }
      DOWNLOAD_URL % [ @server_id, @short_host, download_params.to_query ]
    end
  
    # Says whether file has been successfully downloaded.
    #
    def downloaded?
      @downloaded
    end
  
  end

end
