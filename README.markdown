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
```

### Turn Debug mode on/off ###

```ruby
Rapidshare::API.debug(true)
Rapidshare::API.debug(false)
```

### Login ###

```ruby
my_account = Rapidshare::Account.new(:login => 'my_login', :password => 'my_password')
```

View account details:

```ruby
my_account.data
```

### Check Files ###

```ruby
my_account.api.checkfiles(
  'https://rapidshare.com/files/829628035/HornyRhinos.jpg',
  'https://rapidshare.com/files/428232373/HappyHippos.jpg'
)
```

### Download File ###

```ruby
my_account.download('https://rapidshare.com/files/829628035/HornyRhinos.jpg')
```

## Examples ##

In [examples directory](./master/examples/) you will find scripts running on Rapidshare gem which can
be used as simple download clients.

## [TODO](./master/TODO.markdown) ##

## License ##

Copyright (c) 2009-2011 Tomasz Mazur, Lukas Stejskal
