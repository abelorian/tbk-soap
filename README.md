### Info

Implementación en Ruby de pago con WebpayPlus de Transbank.


### Disclaimer

Esta gema no es de Transbank. Aunque está basada al 100% en la documentación de TransbankDevelopers.

## Instalación

Agregar al Gemfile:

```ruby
gem 'tbk-soap'
```

Instalar gemas:

    $ bundle

Or install it yourself as:

    $ gem install tbk-soap

Generador: Falta copiar los archivos de tbk a la carpeta config/tbk

    $ rails generate transbank:install

### Cómo usarla

Add this line to your application's Gemfile:

```ruby
gem 'tbk-soap'
```

Configurar

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

Para generar una nueva transacción

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

Confirmar la transacción

```ruby
class WebpayController < ApplicationController

  # ...

  # Confirmation callback executed from Webpay servers
  # Aqui depende de cada comercio.
  def confirmation
    response = Transbank::Webpay.get_transaction_result(params[:token_ws])
    response_code = response["responsecode"] || -1

    if !Transbank::Webpay.valid_transaction_result?(response_code) || SALE.paid?
      # REDIRECT_TO checkout
    end

    # Execute after 30 seconds
    acknowledge_response = Transbank::Webpay.acknowledge_transaction(params[:token_ws])

    unless SALE.paid?
      SALE.pay! if Transbank::Webpay.valid_acknowledge_result?(acknowledge_response)
      

      
      @urlredirection = response["urlredirection"]
      render "confirmation.html.erb" # ver abajo
    end
    


  end

  # ...

end
```

### Importante

Luego del acknowledge, se debe "redireccionar" a traves del método POST. Si se redirecciona con GET, mostrará "Error de transacción" en el voucher.
Para lograrlo, se usa un formulario en html. Transbank también lo utiliza en el flujo.


```
<!DOCTYPE html>
<html>
<head>
  <title>Welcu</title>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.2.4/jquery.min.js"></script>
</head>
<body>
  <form id="paso" name="paso" action="<%= @urlredirection %>" method="POST">
    <input type='hidden' name='token_ws' value='<%= params["token_ws"] %>' />
  </form>
  <script type="text/javascript">
    $(document).ready(function () {
      setTimeout(function () {
        $("#paso").submit();
      }, 0);
    });
  </script>
</body>
</html>
```


### Pruebas


**Tarjeta de crédito:**

N° tarjeta de crédito	4051885600446623

Año de expiración	Cualquiera

Mes de expiración	Cualquiera

CVV	123

**Banco:**

Rut	11111111-1

Clave	123

