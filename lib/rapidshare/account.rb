# encoding: utf-8

# Provides user-friendly interface to +Rapidshare::API+ class.
#
# This is still work in progress.
#
class Rapidshare::Account

  attr_reader :api, :data
  
  # Logs into Rapidshare account as a premium user.
  # 
  # Params:
  # * *login* - premium account login
  # * *password* - premium account password
  #
  def initialize(params = {})
    @api = Rapidshare::API.new(params)
    @data = @api.get_account_details
  end
  
  # Reloads account data.
  #
  def reload!
    @data = api.get_account_details
  end
  
  # Downloads file.
  #
  # Options:
  # * *filename* (optional) - specifies filename under which the file will be
  #   saved. Default: filename parsed from Rapidshare link.
  # * *downloads_dir* (optional) - specifies directory into which downloaded files
  #   will be saved. Default: current directory.
  #
  def download(file, options = {})
    api.download(file, options)
  end

end
