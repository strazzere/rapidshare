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
require 'rubygems'
require 'rapidshare'

files_to_download = %w{
  https://rapidshare.com/files/829628035/HornyRhinos.jpg
  https://rapidshare.com/files/428232373/HappyHippos.jpg
  https://rapidshare.com/files/766059293/ElegantElephants.jpg
}

rs = Rapidshare::API.new(:login => 'my_login', :password => 'my_password')

files_to_download.each do |file|
  result = rs.download(file)

  unless result.downloaded? 
    puts "[#{file}] cannot be downloaded: #{result.error}"
  end
end
```

## Login ##

Rapidshare gem is meant to be used mostly by premium users. In order to call Rapidshare
services as premium user, you need to log in first, using your  *login* and *password*.

```ruby
rs = Rapidshare::API.new(:login => 'my_login', :password => 'my_password')
```

Alternatively you can use *cookie* parameter, which stores encrypted *login* and
*password* parameters.

```ruby
rs = Rapidshare::API.new(:cookie => 'my_cookie')
```

Best practice is to use cookie. You probably don't want to enter your Rapidshare
password every time or have it stored in some config file on your hard drive. 

### How to get Rapidshare cookie

```ruby
Rapidshare::API.new(:login => 'my_login', :password => 'my_password').cookie
```

## Rapidshare Services ##

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

## Service Calls ##

All calls to Rapidshare services are done internally by `API#request` method:

Syntax:

```ruby
request(service_name, params_in_hash)
```

Example:

```ruby
Rapidshare::API.request(:getaccountdetails, :login => 'my_login', :password => 'my_password')
```

Use this method to call Rapidshare services which don't have dedicated methods
available in this gem.

### Parser Parameter ###

`API#request` method has an optional parameter *:parser* which specifies how to 
parse the response from Rapidshare. (Rapidshare doesn't unified API, there are
several "types" of responses.) Following options are supported at the moment:

* *:none* - default, returns response body as it is
* *:csv* - parses response like CSV file into array of arrays
* *:hash* - parses response like a hash - *key=value* strings separated by newlines

Example:

```ruby
rs.request(:getaccountdetails, :parser => :hash)
```

PS: cookie is automatically added if you call request method on a Rapidshare instance 

### Method Missing ###

Let's say you want to call service for which rapidshare gem doesn't have
dedicated method yet, for example: *getrapidtranslogs* . While you can
explicitly call `API#request` method:

```ruby
rs.request(:getrapidtranslogs, :parser => 'csv')
```

the cooler way is to make a service call using `API#method_missing`:

```ruby
rs.getrapidtranslogs(:parser => 'csv')
```

If you call an uknown method on `API` instance, `missing_method` assumes
that you want to make a service call to Rapidshare and invokes the `request`
method, using the missing method name as service name and passing any available
params. For example:

```ruby
rs.getrapidtranslogs(:parser => 'csv')
```

invokes

```ruby
rs.request(:getrapidtranslogs, :parser => 'csv')
```

`method_missing` also removes any underscores from the service name, so these
method calls are equivalent:

```ruby
rs.getrapidtranslogs == rs.get_rapid_trans_logs
```

This is used for aliasing dedicated methods as well: `rs.get_account_details`
invokes `rs.getaccountdetails`. In this case the corresponding dedicated
method is called instead of low-level `request` method, because we check for
existense of dedicated method first.

## Examples ##

In [examples directory](./master/examples/) you will other examples of using
Rapidshare gem. Among other things there are scripts which can serve as simple
download clients.

## License ##

Copyright (c) 2009-2011 Tomasz Mazur, Lukas Stejskal
