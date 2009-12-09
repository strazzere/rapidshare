class Rapidshare::API::Error < StandardError
  
  def initialize(error)
    @error = error
  end
  
  def to_s
    @error.sub('ERROR: ', "")
  end

end
