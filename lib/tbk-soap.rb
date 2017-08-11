require "base64"
require "openssl"
require "nokogiri"
require "digest/sha1"
require 'net/https'

require "tbk/config"
require "tbk/verifier"
require "tbk/api"
require "tbk/client"
require "tbk/document"

class TbkSoap
  def api
    @api ||= TBK::Api.new
  end
end