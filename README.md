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

    $ rails generate tbk_ws:install

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
    @payment = TBK::Webpay::Payment.new({
      request_ip: request.ip,
      amount: ORDER_AMOUNT,
      order_id: ORDER_ID,
      success_url: webpay_success_url,
      # Webpay can only access the HTTP protocol to a direct IP address (keep that in mind)
      confirmation_url: webpay_confirmation_url(host: SERVER_IP_ADDRESS, protocol: 'http'),

      # Optionaly supply:
      session_id: SOME_SESSION_VALUE,
      failure_url: webpay_failure_url # success_url is used by default
    })

    # Redirect the user to Webpay
    redirect_to @payment.redirect_url
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
    # Read the confirmation data from the request
    @confirmation = TBK::Webpay::Confirmation.new({
      request_ip: request.ip,
      body: request.raw_post
    })

    if # confirmation is invalid for some reason (wrong order_id or amount, double payment, etc...)
      render text: @confirmation.reject
      return # reject and stop execution
    end

    if @confirmation.success?
      # EXITO!
      # perform everything you have to do here.
    end

    # Acknowledge payment
    render text: @confirmation.acknowledge
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

