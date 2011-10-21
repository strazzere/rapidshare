# encoding: utf-8

# TODO replace with Net::HTTPS or Curb
require "httparty"
require 'curb'
require 'progressbar'
# active_support cherry-picks
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/hash/keys'

require "rapidshare/rapidshare"
require "rapidshare/api"
require "rapidshare/error"
require "rapidshare/download"