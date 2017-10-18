TBK::Api.configuration do |configuration|
  configuration.wsdl_transaction_url = 'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl'
  configuration.wsdl_nullify_url     = 'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSCommerceIntegrationService?wsdl'
  configuration.cert_path            = 'config/tbk/597020000541.crt'
  configuration.key_path             = 'config/tbk/597020000541.key'
  configuration.server_cert_path     = 'config/tbk/tbk.pem'
  configuration.commerce_code        = '597020000541'
end
