module TBK
  class Config
    attr_accessor :wsdl_transaction_url
    attr_accessor :wsdl_nullify_url

    attr_accessor :commerce_code

    attr_accessor :cert_path
    attr_accessor :key_path
    attr_accessor :server_cert_path

    attr_accessor :rescue_exceptions

    attr_accessor :http_options

    def initialize
      @rescue_exceptions = [
        Net::ReadTimeout, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
        EOFError, Net::HTTPBadGateway, Net::HTTPBadResponse,
        Net::HTTPHeaderSyntaxError, Net::ProtocolError
      ]

      @http_options = {}
    end

    def self.config
      @config ||= Config.new
    end
  end
end
