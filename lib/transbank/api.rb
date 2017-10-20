require 'signer'
require 'savon'

module Transbank
  class Api

    def client
      @client ||= Transbank::Client.new
    end

    def config
      Transbank::Webpay.configuration
    end

    def init_data(amount, buyOrder, sessionId, returnURL = nil, finalURL = nil)

      commerce_code = config.commerce_code
      returnURL = returnURL || "http://localhost:3000?action=result"
      finalURL = finalURL || "http://localhost:3000?action=end"

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

    def init_transaction amount, buyOrder, sessionId, return_url = nil, final_url = nil
      input = init_data(amount, buyOrder, sessionId, return_url, final_url)
      document = client.make_request(:init_transaction, input)
      return document if document.to_s == "INVALID"
      return Transbank::Document.get_xml_values(['url', 'token'], document)
    end

    def get_transaction_result token
      input = {"tokenInput" => token}
      document = client.make_request(:get_transaction_result, input)
      keys = ["paymenttypecode", "vci", "signaturevalue", "keyinfo", "securitytokenreference", "buyorder", "carddetail", "cardnumber", "amount", "authorizationcode",
        "responsecode", "sessionid", "transactiondate", "sharesnumber", "urlredirection"]
      return Transbank::Document.get_xml_values(keys, document)
      #return document
    end

    def valid_transaction_result?(response_code)      
      response_code.to_s == "0"
    end

    def acknowledge_transaction token
      input = {"tokenInput" => token}
      document = client.make_request(:acknowledge_transaction, input)
      return document if document.to_s == "INVALID"
      return Transbank::Document.get_xml_values(["tokeninput"], document)
    end

    def valid_acknowledge_result? response
      return false if response.to_s.length < 10 && response.to_s == "INVALID"
      return true if response.to_s.length > 10 && response.to_s != "INVALID" && response["tokeninput"].present?
    end

  end

end

