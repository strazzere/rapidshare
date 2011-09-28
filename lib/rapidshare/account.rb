
# This class provides (or should) user-friendly interface to RapidShare::API class.
#
class Rapidshare::Account

  attr_reader :api, :data
  
  # log into Rapidshare account as premium user
  # 
  def initialize(login, password)
    @api = Rapidshare::API.new(login, password)
    @data = @api.get_account_details
  end
  
  # reload account data
  #
  def reload!
    @data = api.get_account_details
  end
  
  # download file
  #
  # options:
  # * save_as - save file under different filename
  # * downloads_dir - save file into specific directory (default: current directory)
  #
  def download(file, options = {})
    Rapidshare::Download.new(file, api, options).perform
  end

end
