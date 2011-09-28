
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

  def read_fixture(filename, extension = 'txt')
    # add extension to file unless it already has it
    filename += ".#{extension}" unless (filename =~ /\.\w+$/)
    
    File.read File.expand_path(File.dirname(__FILE__) + "/fixtures/#{filename}")
  end

end
