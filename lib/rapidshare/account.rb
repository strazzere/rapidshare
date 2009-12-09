class Rapidshare::Account

  attr_reader :cookie, :data

  def initialize(login, password, type)
    @data = Rapidshare::API.get_account_details(login, password, type)
  end
  
  def type
    data["type"].eql?("prem") ? :premium : :collector
  end
  
  def reload!
    @data = Rapidshare::API.get_account_details_with_cookie(cookie)
  end
  
  def account_id
    data["accountid"].to_i
  end
  
  def email
    data["email"]
  end
  
  def username
    data["username"]
  end
  
  def security_lock_enabled?
    data["rsantihack"].eql?("1")
  end
  
  def js_config_enabled?
    data["jsconfig"].eql?("1")
  end
    
  def server_time
    Time.at(data["servertime"].to_i)
  end
  
  def created_at
    Time.at(data["addtime"].to_i)
  end
  
  def mirrors
    data["mirrors"].split(",")
  end
  
  def lots
    data["lots"].to_i
  end
  
  def cookie
    return unless data["cookie"]
    data["cookie"]
  end
  
  def ref_string
    return unless data["refstring"]
    data["refstring"]
  end
  
  def free_rapid_points
    data["fpoints"].to_i
  end
  
  def premium_rapid_points
    data["ppoints"].to_i
  end
  
  def exchange_rate
    data["ppointrate"].to_f / 100
  end
    
  def current_files
    data["curfiles"].to_i
  end
  
  def current_space
    data["curspace"].to_i
  end
  
  def download(file, save_as = nil)
    # check few things
    Rapidshare::Download.new(file, cookie, save_as)
  end

end

class Rapidshare::PremiumAccount < Rapidshare::Account
  
  def initialize(login, password)
    super(login, password, "prem")
  end
  
  def expires_at
    Time.at(data["validuntil"].to_i)
  end
  
  def expired?
    server_time >= expires_at
  end
  
  def traffic_left
    data["premkbleft"].to_i
  end
  
  def traffic_share_left
    data["bodkb"].to_i
  end
  
  def plus_traffic_mode_enabled?
    data["plustrafficmode"].eql?("1")
  end
  
  def direct_downloads_enabled?
    data["directstart"].eql?("1")
  end
    
end

class Rapidshare::CollectorAccount < Rapidshare::Account
  
  def initialize(login, password)
    super(login, password, "col")
  end
  
end
