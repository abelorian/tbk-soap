module TBK
  class Document

    def initialize
      @public_cert = OpenSSL::X509::Certificate.new(open TBK::Config.config.cert_path)
      @private_key = OpenSSL::PKey::RSA.new(open TBK::Config.config.key_path)
      @webpay_cert = OpenSSL::X509::Certificate.new(open TBK::Config.config.server_cert_path)
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

    def self.get_xml_values keys, document
      data = {}
      parsed_xml = Nokogiri::HTML(document.to_s)
      keys.each do |key|
        parsed_xml.xpath("//" + key).each do |v|
          data.merge!({key.to_s => v.text})
        end        
      end
      return data
    end

    def is_a_valid_document? document
      tbk_cert = @webpay_cert
      if !Verifier.verify(document, tbk_cert)
        puts "El Certificado es Invalido."
        return true
      else
        puts "El Certificado es Valido."
        return false
      end
    end

  end
end