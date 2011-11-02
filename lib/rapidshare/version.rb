# encoding: utf-8

module Rapidshare
  VERSION = "0.5.0"

  # CHANGELOG:
  #
  # 0.5.0
  # wrote documentation
  # wrote tests
  # refactored API class
  # changed HTTP client for API class: replace HTTParty with Net::HTTPS
  # removed obsolete Account class
  # enabled login with cookie only
  # add API#method_missing for unsupported Rapidshare service calls
  #
  # 0.4.5
  # rewrote download method from Net:HTTP to Curb gem
  # added download scripts as examples of use of rapidshare gem
  #
end
