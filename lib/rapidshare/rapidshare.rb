
# active_support cherry-picks
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/hash/keys'

class Rapidshare

  FILE_REGEXP = /\Ahttps?:\/\/rapidshare.com\/files\/([0-9]+)\/(.+)\z/ix unless defined?(FILE_REGEXP)

  def self.build_file_url(server_id, short_host, file_id, file_name)
    "https://rs#{server_id}#{short_host}.rapidshare.com/files/#{file_id}/#{file_name}"
  end

end
