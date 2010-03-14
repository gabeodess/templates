module PaypalHelper
  
  def form_for_paypal(line_items, options = {})
    form_tag APP_CONFIG['paypal_url'] do
       hidden_field_tag(:cmd, "_s-xclick") +
       hidden_field_tag(:encrypted, paypal_encrypted(line_items)) +
    	"<p>Upon clicking the checkout button below you will be redirected to PayPal where you can purchase your item.</p>" +
      content_tag(:p, submit_tag("Checkout", :disable_with => "Redirecting to PayPal..."))
     end 
  end
  
  def paypal_encrypted(line_items, options = {})
    return_url = options[:return_url] || root_url
    notify_options = options[:notify_options] || {}
    notify_url = payment_notifications_url({:secret => APP_CONFIG['paypal_secret']}.merge(notify_options))
    values = {
      :business => APP_CONFIG['paypal_email'],
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :invoice => id,
      :notify_url => notify_url,
      :cert_id => APP_CONFIG['paypal_cert_id']
    }
    line_items.each_with_index do |item, index|
      values.merge!({
        "amount_#{index+1}" => item.unit_price,
        "item_name_#{index+1}" => item.product_name,
        "item_number_#{index+1}" => item.id,
        "quantity_#{index+1}" => item.quantity
      })
    end
    encrypt_for_paypal(values)
  end

  PAYPAL_CERT_PEM = File.read("#{Rails.root}/certs/paypal_cert.pem")
  APP_CERT_PEM = File.read("#{Rails.root}/certs/app_cert.pem")
  APP_KEY_PEM = File.read("#{Rails.root}/certs/app_key.pem")

  def encrypt_for_paypal(values)
    signed = OpenSSL::PKCS7::sign(
      OpenSSL::X509::Certificate.new(APP_CERT_PEM), 
      OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), 
      values.map { |k, v| "#{k}=#{v}" }.join("\n"), 
      [], 
      OpenSSL::PKCS7::BINARY
    )
    OpenSSL::PKCS7::encrypt(
      [OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], 
      signed.to_der, 
      OpenSSL::Cipher::Cipher::new("DES3"), 
      OpenSSL::PKCS7::BINARY
    ).to_s.gsub("\n", "")
  end
  
  
end