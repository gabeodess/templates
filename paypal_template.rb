generate :controller, 'paypal'
file "app/views/paypal/index.html.erb", open('../templates/views/paypal/index.html.erb').read

generate :scaffold, 'PaymentNotification params:text transaction_id:string status:string payer_email:string payment_gross:float invalid_secret:boolean'
run 'rm app/views/layouts/payment_notifications.html.erb'

file "config/paypal_config.yml", open('../templates/config/paypal_config.yml').read
file "config/initializers/load_paypal_config.rb", open('../templates/initializers/load_paypal_config.rb').read
file "lib/paypal.rb", open('../templates/lib/paypal.rb').read
file "certs/README.rdoc", open('../templates/readmes/cert_readme.txt').read

@todos ||= []
@todos << "Edit config/paypal_config.yml to contain your paypal credentials."
@todos << "Copy your paypal certificates to the 'certs' directory."

load_template "../templates/base_template.rb"