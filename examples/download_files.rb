
require 'rubygems'
require 'rapidshare'

files_to_download = %w{
  https://rapidshare.com/files/829628035/HornyRhinos.jpg
  https://rapidshare.com/files/428232373/HappyHippos.jpg
  https://rapidshare.com/files/766059293/ElegantElephants.jpg
}

rs = Rapidshare::Account.new('my_login','my_password')

files_to_download.each do |file|
  response = rs.api.check_files([file])
  
  unless (response.first[:file_status] == :ok)
    p "File not found"
    next
  end
  
  rs.download(file)
end
