require 'signer'
require 'savon'
require_relative "verifier"

module TBK
  class Api

    def initialize
      @wsdl_path = config.wsdl_transaction_url
      @commerce_code = config.commerce_code
      @private_key = OpenSSL::PKey::RSA.new(open config.key_path)
      @public_cert = OpenSSL::X509::Certificate.new(open config.cert_path)
      @webpay_cert = OpenSSL::X509::Certificate.new(open config.server_cert_path)
      # @ambient = configuration.get(ambient)        
      @client = client
    end

    def client
      TBK::Client.new.client
    end

    def config
      TBK::Config.config
    end

    def init_data(amount, buyOrder, sessionId)
      {
        "wsInitTransactionInput" => {
          "wSTransactionType" => "TR_NORMAL_WS",
          "buyOrder" => buyOrder,
          "sessionId" => sessionId,
          "returnURL" => "http://localhost:3000/tbk-normal-controller.rb?action=result",
          "finalURL" => "http://localhost:3000/tbk-normal-controller.rb?action=end",
          "transactionDetails" => {
            "amount" => amount,
            "commerceCode" => @commerce_code,
            "buyOrder" => buyOrder
          }
        }
      }
    end

    def init_transaction(amount, buyOrder, sessionId)

      initInput = init_data(amount, buyOrder, sessionId)

      req = @client.build_request(:init_transaction, message: initInput)
      document = sign_xml(req)
      begin
        response = @client.call(:init_transaction) do
          xml document.to_xml(:save_with => 0)
        end

      rescue Exception, RuntimeError
        raise
      end

      token=''
      response_document = Nokogiri::HTML(response.to_s)
      response_document.xpath("//token").each do |token_value|
        token = token_value.text
      end

      url=''
      response_document.xpath("//url").each do |url_value|
        url = url_value.text
      end

      tbk_cert = OpenSSL::X509::Certificate.new(@webpay_cert)
      if !Verifier.verify(response, tbk_cert)
        puts "El Certificado es Invalido."
      else
        puts "El Certificado es Valido."
      end

      response_array ={
        "token" => token.to_s,
        "url" => url.to_s
      }

      return response_array
    end

    def sign_xml (input_xml)
      document = Nokogiri::XML(input_xml.body)
      envelope = document.at_xpath("//env:Envelope")
      envelope.prepend_child("<env:Header><wsse:Security xmlns:wsse='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd' wsse:mustUnderstand='1'/></env:Header>")
      xml = document.to_s
      signer = Signer.new(xml)
      signer.cert = OpenSSL::X509::Certificate.new(@public_cert)
      signer.private_key = OpenSSL::PKey::RSA.new(@private_key)
      signer.document.xpath("//soapenv:Body", { "soapenv" => "http://schemas.xmlsoap.org/soap/envelope/" }).each do |node|
        signer.digest!(node)
      end

      signer.sign!(:issuer_serial => true)
      signed_xml = signer.to_xml
      document = Nokogiri::XML(signed_xml)
      x509data = documentAck.at_xpath("//*[local-name()='X509Data']")
      new_data = x509data.clone()
      new_data.set_attribute("xmlns:ds", "http://www.w3.org/2000/09/xmldsig#")
      n = Nokogiri::XML::Node.new('wsse:SecurityTokenReference', document)
      n.add_child(new_data)
      x509data.add_next_sibling(n)
      return document
    end


  end

end

