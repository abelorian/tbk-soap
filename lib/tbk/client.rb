module TBK

  class Client

    attr_accessor :client

    def client
      @client ||= Savon.client(wsdl: TBK::Config.config.wsdl_transaction_url)
    end
  end

end