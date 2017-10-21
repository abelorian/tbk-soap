### About

This is a pure ruby implementation of Transbank's SOAP service.


### Disclaimer

This library is not developed, supported nor endorsed in any way by Transbank S.A.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tbk-soap'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tbk-soap

Run the generator:

    $ rails generate transbank:install

### Usage

Add this line to your application's Gemfile:

```ruby
gem 'tbk-soap'
```

Configure your commerce

```ruby
Transbank::Webpay.configure do |config|
  config.wsdl_transaction_url = 'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl'
  config.wsdl_nullify_url     = 'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSCommerceIntegrationService?wsdl'
  config.cert_path            = 'config/tbk/597020000541.crt'
  config.key_path             = 'config/tbk/597020000541.key'
  config.server_cert_path     = 'config/tbk/tbk.pem'
  config.commerce_code        = '597020000541'
end
```

To start a payment from your application

```ruby
class WebpayController < ApplicationController

  # ...

  # Start a payment
  def pay
    # Setup the payment
    @payment = Transbank::Webpay.init_transaction(SALE_TOTAL, SALE_ID, USER_ID, CONFIRMATION_URL, SUCCESS_URL)

    # Redirect the user to Webpay
    redirect_to @payment["url"] + "?token_ws=" + @payment["token"]
  end

  # ...
end
```

And to process a payment

```ruby
class WebpayController < ApplicationController

  # ...

  # Confirmation callback executed from Webpay servers
  def confirmation
    response = Transbank::Webpay.get_transaction_result(params[:token_ws])
    response_code = response["responsecode"] || -1

    if !Transbank::Webpay.valid_transaction_result?(response_code) || SALE.paid?
      # REDIRECT_TO checkout
    end

    # Execute after 30 seconds
    acknowledge_response = Transbank::Webpay.acknowledge_transaction(params[:token_ws])

    unless @sale.paid?
      SALE.pay! if Transbank::Webpay.valid_acknowledge_result?(acknowledge_response)
    end
    redirect_to response["urlredirection"] + "?token_ws=" + params[:token_ws].to_s

  end

  # ...

end
```

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

