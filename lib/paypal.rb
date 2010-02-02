class Paypal
  
  def self.paypal_values(notify_url, my_return_url = nil, options = {})

    return_url = my_return_url.blank? ? nil : 'http://' + my_return_url.gsub(/^w+:\/\//,'')
    values = {
      :business => APP_CONFIG['paypal_email'],
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :notify_url => notify_url,
      :cert_id => APP_CONFIG['paypal_cert_id'],
      :amount_1 => options[:price],
      :item_name_1 => options[:title],
      :item_number_1 => options[:id]
    }
    return values
  end
  
  def self.paypal_encrypted(notify_url, my_return_url = nil, options = {})
    encrypt_for_paypal(paypal_values(notify_url, my_return_url, options = {}))
  end
  
  PAYPAL_CERT_PEM = File.read("#{Rails.root}/certs/paypal_cert.pem")
  APP_CERT_PEM = File.read("#{Rails.root}/certs/app_cert.pem")
  APP_KEY_PEM = File.read("#{Rails.root}/certs/app_key.pem")
  
  def self.encrypt_for_paypal(values)
    signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(APP_CERT_PEM), OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
    OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
  end
  
end