# Rapidshare #

## Description ##

This gem provides a wrapper for RapidShare API.

Full documentation of RapidShare API is available at
[http://images.rapidshare.com/apidoc.txt](http://images.rapidshare.com/apidoc.txt)

## Installation ##

```ruby
gem install rapidshare
```

## Usage ##

```ruby
require 'rapidshare'

files_to_download = %w{
  https://rapidshare.com/files/829628035/HornyRhinos.jpg
  https://rapidshare.com/files/428232373/HappyHippos.jpg
  https://rapidshare.com/files/766059293/ElegantElephants.jpg
}

rs = Rapidshare::API.new(:login => 'my_login', :password => 'my_password')

files_to_download.each do |file|
  result = rs.download(file)
  puts "[#{file}] cannot be downloaded: #{result.error}" unless result.downloaded? 
end
```

### Get Account Details ###

```ruby
rs.get_account_details
```

### Check Files ###

```ruby
rs.check_files(
  'https://rapidshare.com/files/829628035/HornyRhinos.jpg',
  'https://rapidshare.com/files/428232373/HappyHippos.jpg',
  'https://rapidshare.com/files/766059293/ElegantElephants.jpg'
)
```

### Download File ###

```ruby
rs.download('https://rapidshare.com/files/829628035/HornyRhinos.jpg')
```

## Examples ##

In [examples directory](./master/examples/) you will find scripts running on Rapidshare gem which can
be used as simple download clients.

## [TODO](./master/TODO.markdown) ##

## License ##

Copyright (c) 2009-2011 Tomasz Mazur, Lukas Stejskal
