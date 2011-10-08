# encoding: utf-8

class Rapidshare::API::Error < StandardError; end
class Rapidshare::API::Error::LoginFailed < StandardError; end
class Rapidshare::API::Error::InvalidRoutineCalled < StandardError; end
