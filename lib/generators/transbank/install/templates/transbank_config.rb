Tbk::Webpay.configure do |config|
  config.wsdl_transaction_url = 'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl'
  config.wsdl_nullify_url     = 'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSCommerceIntegrationService?wsdl'
  config.cert_path            = 'config/tbk/597020000541.crt'
  config.key_path             = 'config/tbk/597020000541.key'
  config.server_cert_path     = 'config/tbk/tbk.pem'
  config.commerce_code        = '597020000541'
end

p "load tbk_ws"