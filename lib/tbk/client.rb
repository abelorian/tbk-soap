module TBK

  class Client

    def initialize
      @client = client
    end

    def client
      @client ||= Savon.client(wsdl: TBK::Config.config.wsdl_transaction_url)
    end

    def make_request action, message_data
      req = @client.build_request(action.to_sym, message: message_data)
      document = TBK::Document.new.sign_xml(req)
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

  end

end