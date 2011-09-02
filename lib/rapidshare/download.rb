require 'curb'
require 'progressbar'

#
# Downloading by RapidShare API consists of two steps:
# * "try download" - request file to download and get server address where to
#   download it from
# * actual download
#
class Rapidshare::Download
  DOWNLOAD_URL = 'https://%s/cgi-bin/rsapi.cgi?%s'

  attr_reader :url, :api, :fileid, :filename, :downloads_dir

  def initialize(url, api, options = {})
    @url = url
    @api = api
    @fileid, @filename = get_fileid_and_filename()
    @filename = options[:save_as] if options[:save_as]
    @downloads_dir = options[:downloads_dir] || Dir.pwd
  end

  def perform
    download_params = { :sub => 'download', :fileid => @fileid, :filename => @filename, :cookie => @api.cookie }
    # get hostname from try_download request (which returns file info including
    # server on which is the file stored)
    #
    # TODO use ActiveSupport#to_query method for creating params string
    request = DOWNLOAD_URL % [get_hostname(), download_params.map { |k,v| "#{k}=#{v}" }.join('&') ]
    
    f = open(File.join(downloads_dir, filename), 'wb')

    bar = nil

    c = Curl::Easy.new(request) do |curl|
      # TODO refactor on_progress code, I'm sure it can be done better
      curl.on_progress do |dl_total, dl_now, ul_total, ul_now|

        if (dl_total > 0) and bar.nil?
          bar = ProgressBar.new(@filename, dl_total)
          bar.file_transfer_mode
        end

        bar.set(dl_now) if (dl_now > 0)

        (dl_now <= dl_total)
      end 

      curl.on_body { |d| f << d; d.length }
    end

    c.perform

    f.close

    puts "" # new line after progressbar finishes
  end

  # parse fileid and filename from rapidshare url
  # example: https://rapidshare.com/files/[fileid]/[filename]
  #
  def get_fileid_and_filename
    @url.split('/').slice(-2,2)
  end

  # get name of the server which hosts the file for download
  # this is done by "try download", downloading file with try=1 parameter
  #
  def get_hostname
    response = @api.request('download', :fileid => @fileid, :filename => @filename, :try => 1).body
  
    # DL:$hostname,$dlauth,$countdown,$md5hex
    # example: DL:rs370tl3.rapidshare.com,0,0,8700146036606454677EFAFB4A2AC52E
    # dlauth and countdown are always 0 for premium accounts
    response.slice!(0,3) # remove "DL:" 
    response.split(',').first
  end

end
