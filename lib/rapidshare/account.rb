class Rapidshare::Account

  attr_reader :api, :data

  def initialize(login, password)
    @api = Rapidshare::API.new(login, password)
    @data = @api.get_account_details
  end
  
  def reload!
    @data = api.get_account_details
  end
  
  def download(file, save_as = nil)
    # check few things
    download = Rapidshare::Download.new(file, api, save_as)
    download.start
  end

end
