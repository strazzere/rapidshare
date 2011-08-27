require 'curb'
require 'progressbar'

class Rapidshare::Download
  DOWNLOAD_URL = 'https://%s/cgi-bin/rsapi.cgi?%s'

  def self.perform(url, api, options = {})
    fileid, filename = fileid_and_filename(url)    

    # 1. try download - get name of the server which hosts the file
    response = api.request('download', :fileid => fileid, :filename => filename, :try => 1).body
 
    # DL:$hostname,$dlauth,$countdown,$md5hex
    # example: DL:rs370tl3.rapidshare.com,0,0,8700146036606454677EFAFB4A2AC52E
    # dlauth and countdown are always 0 for premium accounts
    response.slice!(0,3) # remove "DL:"
    hostname = response.split(',').first

    # 2. actual download
    download_params = { :sub => 'download', :fileid => fileid, :filename => filename, :cookie => api.cookie }
    # TODO use ActiveSupport#to_query method for creating params string
    request = DOWNLOAD_URL % [hostname, download_params.map { |k,v| "#{k}=#{v}" }.join('&') ]

    filename = options[:save_as] if options[:save_as]

    f = open(filename, 'wb')

    bar = nil

    c = Curl::Easy.new(request) do |curl|
      # TODO refactor on_progress code, I'm sure it can be done better
      curl.on_progress do |dl_total, dl_now, ul_total, ul_now|

        if (dl_total > 0) and bar.nil?
          bar = ProgressBar.new(filename, dl_total)
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

  protected

  # parse fileid and filename from rapidshare url
  # example: https://rapidshare.com/files/[fileid]/[filename]
  #
  def self.fileid_and_filename(url)
    url.split('/').slice(-2,2)
  end

end
