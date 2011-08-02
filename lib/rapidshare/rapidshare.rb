class Rapidshare

  FILE_REGEXP = /\Ahttps?:\/\/rapidshare.com\/files\/([0-9]+)\/(.+)\z/ix unless defined?(FILE_REGEXP)

  def self.build_file_url(server_id, short_host, file_id, file_name)
    "http://rs#{server_id}#{short_host}.rapidshare.com/files/#{file_id}/#{file_name}"
  end

  @@debug = false
  
  # return values of debug switch (default: false). if it's set to true, gem
  # will display raw API calls
  #
  def self.debug?; @@debug; end

  # turn on debugging
  #
  def self.debug_on!; @@debug = true; end
  
  # turn off debugging
  #
  def self.debug_off!; @@debug = false; end

end
