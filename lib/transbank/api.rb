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
      response = Transbank::Document.get_xml_values(['url', 'token'], document)
      show_log("init_transaction response", response)
      return response
    end

    def get_transaction_result token
      input = {"tokenInput" => token}
      document = client.make_request(:get_transaction_result, input)
      return document if document.to_s == "INVALID"
      keys = ["paymenttypecode", "vci", "signaturevalue", "keyinfo", "securitytokenreference", "buyorder", "carddetail", "cardnumber", "amount", "authorizationcode",
        "responsecode", "sessionid", "transactiondate", "sharesnumber", "urlredirection"]
      response = Transbank::Document.get_xml_values(keys, document)
      show_log("get_transaction_result response", response)
      return response
    end

    def valid_transaction_result?(response_code)      
      response_code.to_s == "0"
    end

    def acknowledge_transaction token
      input = {"tokenInput" => token}
      document = client.make_request(:acknowledge_transaction, input)
      if document.to_s == "INVALID"
        response = document
      else
        response = Transbank::Document.get_xml_values(["signature"], document)
      end
      show_log("acknowledge_transaction response", response)
      return response
    end

    def valid_acknowledge_result? response
      return false if response.to_s.length < 10 && response.to_s == "INVALID"
      return true if response.to_s.length > 10 && response.to_s != "INVALID" && response["signature"].present?
    end

    def show_log key, message
      p 
      p "----- Transbank Webpay log: #{key} ------"
      p ""
      p message
    end

  end

end

