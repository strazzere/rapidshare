#!/usr/bin/env ruby

require 'rubygems'
require 'rapidshare'

files_to_download = %w{
  https://rapidshare.com/files/829628035/HornyRhinos.jpg
  https://rapidshare.com/files/428232373/HappyHippos.jpg
  https://rapidshare.com/files/766059293/ElegantElephants.jpg
}

rs = Rapidshare::API.new('my_login','my_password')

files_to_download.each do |file|
  result = rs.download(file)
  puts "[#{file}] cannot be downloaded: #{result.error}" unless result.downloaded? 
end
