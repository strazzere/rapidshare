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

This example shows a simple script which downloads files from Rapidshare:

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

## Login ##

Rapidshare gem is meant mostly for premium users. In order to call Rapidshare
services as premium user, you need to log in first, using +login+ and +password+.

```ruby
rs = Rapidshare::API.new(:login => 'my_login', :password => 'my_password')
```

Alternatively you can use encrypted +cookie+ parameter, where the +login+ and
+password+ parameters are stored.

```ruby
rs = Rapidshare::API.new(:cookie => '')
```

Best practice is to use cookie. You probably don't want to enter your Rapidshare
password every time or have it stored in some config file on your hard drive. 

## Supported Services ##

+API#request+ method provides minimal interface to all services of Rapidshare
API. However, some important services also have dedicated methods.

As a rule of thumb, you can call these dedicated methods either by their
Rapidshare name (example: +getaccountdetails+), or with properly underscored
name (example: +get_account_details+).

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

In [examples directory](./master/examples/) you will other examples of using
Rapidshare gem. Among other things there are some simple download clients.

## [TODO](./master/TODO.markdown) ##

## License ##

Copyright (c) 2009-2011 Tomasz Mazur, Lukas Stejskal
