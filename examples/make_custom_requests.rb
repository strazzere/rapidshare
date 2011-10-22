#!/usr/bin/env ruby

require 'rubygems'
require 'rapidshare'

# example of making custom request through API#request method

files_to_download = %w{
  https://rapidshare.com/files/829628035/HornyRhinos.jpg
  https://rapidshare.com/files/428232373/HappyHippos.jpg
  https://rapidshare.com/files/766059293/ElegantElephants.jpg
}

rs = Rapidshare::API.new(:login => 'my_login', :password => 'my_password')

p "Account details:"
rs.request(:getaccountdetails, :parser => :hash).each_pair do |k,v|
  p "#{k}: #{v}"
end

p "Transaction log:"
rs.request(:getrapidtranslogs, :parser => :csv).reverse.each do |transaction|
  p "#{transaction[2]} rapids at #{Time.at(transaction[0].to_i)}"
end

