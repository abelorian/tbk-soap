module Transbank
  module Webpay
    VCI = {
      "TSY" => "Autenticación exitosa",
      "TSN" => "Autenticación fallida.",
      "TO" => "Tiempo máximo excedido para autenticación.",
      "ABO" => "Autenticación abortada por tarjetahabiente.",
      "U3" => "Error interno en la autenticación.",
      "EMPTY" => "Error interno en la autenticación."
      }.freeze

    PAYMENT_TYPE_CODE = {
      "VD" => "Venta Debito",
      "VN" => "Venta Normal",
      "VC" => "Venta en cuotas",
      "SI" => "3 cuotas sin interés",
      "S2" => "2 cuotas sin interés",
      "NC" => "N Cuotas sin interés"
      }.freeze

    RESPONSE_CODE = {
      '0'   => 'transacción aprobada',
      '-1'  => 'rechazo de transacción',
      '-2'  => 'transacción debe reintentarse',
      '-3'  => 'error en transacción',
      '-4'  => 'rechazo de transacción',
      '-5'  => 'rechazo por error de tasa',
      '-6'  => 'excede cupo máximo mensual',
      '-7'  => 'excede límite diario por transacción',
      '-8'  => 'rubro no autorizado'
    }
  end
end