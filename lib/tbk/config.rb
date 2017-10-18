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

    def cert_file
      OpenSSL::X509::Certificate.new(open (TBK::Config.config.cert_path || "lib/tbk/keys/597020000541.crt"))
    end

    def private_key
      OpenSSL::PKey::RSA.new(open TBK::Config.config.key_path)
    end

    def webpay_cert
      OpenSSL::X509::Certificate.new(open TBK::Config.config.server_cert_path)
    end

  end
end
