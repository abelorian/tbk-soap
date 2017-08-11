require 'signer'
require 'savon'

module TBK
  class Api

    # require 'tbk-soap'
    # api = TBK::Api.new
    # Transbank api docs: http://www.transbankdevelopers.cl/?m=api

    def initialize
      @client = TBK::Client.new
      # @ambient = configuration.get(ambient)
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
            "commerceCode" => config.commerce_code,
            "buyOrder" => buyOrder
          }
        }
      }
    end

    def get_transaction_result token
      message_data = {
        "tokenInput" => token
      }
      document = @client.make_request(:get_transaction_result, message_data)
      payment_data = {}
      params = ["paymenttypecode", "vci", "signaturevalue", "keyinfo", "securitytokenreference", "buyorder", "carddetail", "cardnumber", "amount", "authorizationcode",
        "responsecode", "sessionid", "transactiondate"]
      params.each do |param|
        payment_data.merge!({param.to_s => get_xml_value(param.to_s, document)})
      end
      #return document
      return payment_data
    end

    def get_xml_value key, document
      parsed_xml = Nokogiri::HTML(document.to_s)
      parsed_xml.xpath("//" + key).each do |v|
        return v.text
      end
    end

    def init_transaction(amount, buyOrder, sessionId)

      message_data = init_data(amount, buyOrder, sessionId)
      document = @client.make_request(:init_transaction, message_data)

      token = get_xml_value("token", document)
      url = get_xml_value("url", document)

      response_array ={
        "token" => token.to_s,
        "url" => url.to_s,
        "init_url" => url.to_s + "?token_ws=" + token.to_s
      }

      return response_array
    end


  end

end

