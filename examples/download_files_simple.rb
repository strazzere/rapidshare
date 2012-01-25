#!/usr/bin/env ruby

require 'rubygems'
require 'rapidshare'

files_to_download = %w{
  https://rapidshare.com/files/829628035/HornyRhinos.jpg
  https://rapidshare.com/files/428232373/HappyHippos.jpg
  https://rapidshare.com/files/766059293/ElegantElephants.jpg
}

rs = Rapidshare::API.new(
                         :login => 'my_login',
                         :password => 'my_password',
                         :proxy => {
                           :proxy_address => 'proxy.address.com',
                           :proxy_port => '8888',
                           :proxy_login => 'my_proxy_login',
                           :proxy_password => 'my_proxy_password'
                         }
                         )

files_to_download.each do |file|
  result = rs.download(file)
  puts "[#{file}] cannot be downloaded: #{result.error}" unless result.downloaded? 
end
