require 'signer'
require 'savon'
require_relative "verifier"

module TBK
  class Api

    # require 'tbk-soap'
    # api = TBK::Api.new
    # req = api.client.build_request(:init_transaction, message: api.init_data(1,2,3))
    # api.sign_xml req
    # Transbank api docs: http://www.transbankdevelopers.cl/?m=api

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

    def init_data(amount, buyOrder, sessionId, returnURL = nil, finalURL = nil)

      returnURL = returnURL || "http://localhost:3000/tbk-normal-controller.rb?action=result"
      finalURL = finalURL || "http://localhost:3000/tbk-normal-controller.rb?action=end"

      return {
        "wsInitTransactionInput" => {
          "wSTransactionType" => "TR_NORMAL_WS",
          "buyOrder" => buyOrder,
          "sessionId" => sessionId,
          "returnURL" => returnURL,
          "finalURL" => finalURL,
          "transactionDetails" => {
            "amount" => amount,
            "commerceCode" => @commerce_code,
            "buyOrder" => buyOrder
          }
        }
      }
    end

    def make_request action, message_data
      req = @client.build_request(action.to_sym, message: message_data)
      document = sign_xml(req)
      begin
        response = @client.call(action.to_sym) do
          xml document.to_xml(:save_with => 0)
        end

      rescue Exception, RuntimeError
        p "---------------- error"
        raise
      end
      response
    end

    def get_transaction_result token
      message_data = {
        "tokenInput" => token
      }
      response = make_request(:get_transaction_result, message_data)
      response_document = Nokogiri::HTML(response.to_s)
    end

    def get_xml_value key, response
      response_document = Nokogiri::HTML(response.to_s)
      response_document.xpath("//" + key).each do |v|
        return v.text
      end
    end

    def init_transaction(amount, buyOrder, sessionId)

      message_data = init_data(amount, buyOrder, sessionId)
      response = make_request(:init_transaction, message_data)

      token = get_xml_value("token", response)
      url = get_xml_value("url", response)

      is_a_valid_cert?(response)

      response_array ={
        "token" => token.to_s,
        "url" => url.to_s,
        "init_url" => url.to_s + "?token_ws=" + token.to_s
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
      x509data = document.at_xpath("//*[local-name()='X509Data']")
      new_data = x509data.clone()
      new_data.set_attribute("xmlns:ds", "http://www.w3.org/2000/09/xmldsig#")
      n = Nokogiri::XML::Node.new('wsse:SecurityTokenReference', document)
      n.add_child(new_data)
      x509data.add_next_sibling(n)
      return document
    end

    def is_a_valid_cert? response
      tbk_cert = OpenSSL::X509::Certificate.new(@webpay_cert)
      if !Verifier.verify(response, tbk_cert)
        puts "El Certificado es Invalido."
        return true
      else
        return false
        puts "El Certificado es Valido."
      end
    end


  end

end

