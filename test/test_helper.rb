
require 'rubygems'
require 'test/unit'

require 'shoulda'
require 'turn'
require 'fakeweb'

require 'rapidshare'

class Test::Unit::TestCase

  # don't allow internet connections for testing (we should use fixtures, except
  # integration testing)
  FakeWeb.allow_net_connect = false

end
