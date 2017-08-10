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

      @wsdl_transaction_url = "https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl"
      @wsdl_nullify_url     = "https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSCommerceIntegrationService?wsdl"
      @commerce_code        = "597020000541"
      @cert_path            = 'lib/tbk/keys/597020000541.crt'
      @key_path             = 'lib/tbk/keys/597020000541.key'
      @server_cert_path     = 'lib/tbk/keys/tbk.pem'
    end

    def self.config
      @config ||= Config.new
    end

  end
end
