require 'signer'
require 'savon'

module Tbk
  class Api

    # require 'tbk-soap'
    # api = TBK::Api.new
    # Transbank api docs: http://www.transbankdevelopers.cl/?m=api

    def client
      @client ||= Tbk::Client.new
    end

    def config
      Tbk::Webpay.configuration
    end

    def init_data(amount, buyOrder, sessionId, returnURL = nil, finalURL = nil)

      commerce_code = Tbk::Config.config.commerce_code
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
            "commerceCode" => commerce_code,
            "buyOrder" => buyOrder
          }
        }
      }
    end

    def init_transaction amount, buyOrder, sessionId
      input = init_data(amount, buyOrder, sessionId)
      document = client.make_request(:init_transaction, input)
      return Tbk::Document.get_xml_values ['url', 'token'], document
    end

    def get_transaction_result token
      input = {"tokenInput" => token}
      document = client.make_request(:get_transaction_result, input)
      keys = ["paymenttypecode", "vci", "signaturevalue", "keyinfo", "securitytokenreference", "buyorder", "carddetail", "cardnumber", "amount", "authorizationcode",
        "responsecode", "sessionid", "transactiondate"]
      return Tbk::Document.get_xml_values keys, document
      #return document
    end

  end

end

