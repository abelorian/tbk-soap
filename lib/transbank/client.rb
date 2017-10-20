module Transbank
  class Client

    def initialize
      @client = client
      @document = Transbank::Document.new
    end

    def client
      @client ||= Savon.client(wsdl: Transbank::Webpay.configuration.wsdl_transaction_url)
    end

    def make_request action, message_data
      show_log("action", action)
      show_log("message_data", message_data)
      req = @client.build_request(action.to_sym, message: message_data)
      show_log("xml_request", req)
      p message_data
      signed_xml = @document.sign_xml(req)
      begin
        response = @client.call(action.to_sym) do
          xml signed_xml.to_xml(:save_with => 0)
        end
      rescue Exception, RuntimeError => e
        p "---------------- error"
        p e.inspect
        return "INVALID"
        raise
      end
      @document.is_a_valid_document? response
      response
    end

    def show_log key, message
      p "----- Transbank Webpay log: #{key}"
      p message
    end
  end
end