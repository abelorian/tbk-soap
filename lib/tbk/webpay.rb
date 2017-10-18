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


module Tbk
  class Webpay

    p "class"

    attr_reader :configuration

    # Delegate api
    Api.instance_methods.each { |m| define_method(m) { |*args| api.send(m, *args) } }

    def configure
      @configuration ||= Config.new
      yield(@configuration)
    end

    def api
      @api ||= Api.new
    end

  end
end