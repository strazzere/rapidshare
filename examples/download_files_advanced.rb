#!/usr/bin/env ruby

# this script is using only Rapidshare::API class, not Rapidshare::Account
# (Account class is just an interface to API, but API class can be used
# completely on its own)

require 'rubygems'
require 'rapidshare'

# load rapidshare settings from YAML file
# 
# example of YAML config file:
#  :login: 'your_login'
#  :password: 'your_password'
#  :cookie: 'your_cookie'
#  :queue: 'path_to_queue/queue_file'
#  :downloads_dir: 'path_to_downloads_dir'
#
settings = YAML::load(File.read(File.join(ENV['HOME'],'.rapidshare'))) rescue nil

# alternatively, if YAML file doesn't exists, set rapidshare manually through hash
settings ||= { :login => 'your_login', :password => 'your_password' }
 
rs = Rapidshare::API.new(:login => settings[:login], :password => settings[:password])

# instead of login and password, you can just set cookie
# rs = Rapidshare::API.new(:cookie => settings[:cookie])
# or just
# rs = Rapidshare::API.new(settings)

# TODO integrate queue parsing into Rapidshare::Account
settings[:queue] ||= 'queue_example.txt'
files_to_download = File.read(settings[:queue]).split(/\s*\n\s*/).select do |line|
  line =~ /^https?\:\/\/rapidshare\.com\/files\/\d+\//
end

# download files to current directory by default
settings[:downloads_dir] ||= Dir.pwd

files_to_download.each do |file|
  result = rs.download(file, :downloads_dir => settings[:downloads_dir])
  puts "[#{file}] cannot be downloaded: #{result.error}" unless result.downloaded? 
end
