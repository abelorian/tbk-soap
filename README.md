### About

This is a pure ruby implementation of Transbank's SOAP service.


### Disclaimer

This library is not developed, supported nor endorsed in any way by Transbank S.A.

### Usage

Add this line to your application's Gemfile:

```ruby
gem 'tbk-soap'
```

Configure your commerce

```ruby
TBK.configure do |config|
  config.commerce_id YOUR_COMMERCE_ID
  config.commerce_key YOUR_RSA_KEY

  # When certifying with Transbank you'll need to use the official logger
  config.webpay_logger :official do |logger|
    # On this path will be the config file and logs in the KCC format.
    logger.directory Rails.root.join('log/webpay')
  end
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

