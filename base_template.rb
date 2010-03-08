# => rails app_name -m templates/base_template.rb

@todos ||= []

run "echo TODO > README"

# =======
# = LIB =
# =======
run "cp ../templates/lib/validator.rb lib/validator.rb"

# =================
# = CONFIGURATION =
# =================
file "config/config.yml", open('../templates/config/config.yml').read
file "config/initializers/load_config.rb", open('../templates/initializers/load_config.rb').read

# ===============
# = STYLESHEETS =
# ===============
file "public/stylesheets/application.css", open("../templates/stylesheets/application.css").read
file "public/stylesheets/gallery.css", open('../templates/stylesheets/gallery.css').read
file "public/stylesheets/overlay.css", open('../templates/stylesheets/overlay.css').read
file "public/stylesheets/validation.css", open('../templates/stylesheets/validation.css').read
file "public/stylesheets/dataTables.css", open('../templates/stylesheets/dataTables.css').read


# ===============
# = JAVASCRIPTS =
# ===============
file "public/javascripts/jquery.js", open('../templates/javascripts/jquery.js').read
file "public/javascripts/jquery-ui.js", open('../templates/javascripts/jquery-ui.js').read
file "public/javascripts/overlay.js", open('../templates/javascripts/overlay.js').read
file "public/javascripts/gallery.js", open('../templates/javascripts/gallery.js').read
file "public/javascripts/expose.js", open('../templates/javascripts/expose.js').read
file "public/javascripts/application.js", open('../templates/javascripts/application.js').read
file "public/javascripts/nav.js", open('../templates/javascripts/nav.js').read

# ========
# = ERBs =
# ========
file "app/views/layouts/application.html.erb", open('../templates/layouts/application.html.erb').read

# ===============
# = CONTROLLERS =
# ===============
file "app/controllers/application_controller.rb", open('../templates/controllers/application_controller.rb').read
generate :controller, "home index"

# ===========
# = HELPERS =
# ===========
file "app/helpers/application_helper.rb", open('../templates/helpers/application_helper.rb').read
file "app/helpers/nav_helper.rb", open('../templates/helpers/nav_helper.rb').read

# ==========
# = IMAGES =
# ==========
run "cp -r ../templates/images/* public/images"

# ================
# = INITIALIZERS =
# ================
file "config/initializers/mime_types.rb", open('../templates/initializers/mime_types.rb').read
file "config/initializers/mime_types.txt", open('../templates/initializers/mime_types.txt').read
file "config/initializers/fields_with_errors.rb", open('../templates/initializers/fields_with_errors.rb').read
file "config/initializers/searchlogic.rb", open('../templates/initializers/searchlogic.rb').read
file "config/initializers/string.rb", open('../templates/initializers/string.rb').read

# ===========
# = PLUGINS =
# ===========
plugin 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git'
plugin 'searchlogic', :git => 'git://github.com/binarylogic/searchlogic.git'

if yes?('Do you want to use Paperclip?')
  plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip' 
  file 'config/initializers/paperclip.rb', open('../templates/initializers/paperclip.rb').read
  file 'app/helpers/paperclip_helper.rb', open('../templates/helpers/paperclip_helper.rb').read
end

if auth = yes?("Do you want to use Restful Authentication?")
  plugin "restful_authentication", :git => "git://github.com/technoweenie/restful-authentication.git"
  name = ask("What do you want a user to be called?")
  generate :authenticated, "#{name} sessions"
  
  if yes?("Do you want to use declarative authorization?")
    plugin "declarative_authorization", :git => "git://github.com/stffn/declarative_authorization.git"
    file "app/helpers/declarative_authorization_helper.rb", open('../templates/helpers/declarative_authorization_helper.rb').read
    generate :scaffold, "Role name:string"
  end
end

if yes?('Would you like to set up gmail as your mail server?')
  plugin 'action_mailer_optional_tls', :git => 'git://github.com/collectiveidea/action_mailer_optional_tls.git'
  run 'cp ../templates/initializers/gmail_config.rb config/initializers/gmail_config.rb'
  
  @todos << "Edit config/initializers/gmail_config.rb to contain your gmail credentials."
end

if yes?('Would you like to set up PayPal as your payments gateway?')
  run "cp ../templates/helpers/paypal_helper.rb app/helpers/paypal_helper.rb"

  generate :scaffold, 'PaymentNotification params:text transaction_id:string status:string payer_email:string payment_gross:float invalid_secret:boolean'
  run 'rm app/views/layouts/payment_notifications.html.erb'

  generate :scaffold, 'LineItem product_id:integer quantity:integer unit_price:decimal'
  run 'rm app/views/layouts/line_items.html.erb'

  file "config/paypal_config.yml", open('../templates/config/paypal_config.yml').read
  file "config/initializers/load_paypal_config.rb", open('../templates/initializers/load_paypal_config.rb').read
  file "certs/README.rdoc", open('../templates/readmes/cert_readme.txt').read

  @todos ||= []
  @todos << "Edit config/paypal_config.yml to contain your paypal credentials."
  @todos << "Copy your paypal certificates to the 'certs' directory."
end


route "map.root :controller => 'home'"
run 'rm public/index.html'

git :init

file ".gitignore", <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/schema.rb
db/*.sqlite3
END

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"

git :add => "."
git :commit => "-am 'adding authentication'"

unless @todos.blank?
  puts "\n\n-----------------------------------------------------------------"
  puts "Your Ruby on Rails application has been created.\nTo get it up and running please complete the items listed below."
  puts "-----------------------------------------------------------------\n\n"
  puts @todos.map{|item| "\t=> #{item}\n\n"}.join
  puts "\n-----------------------------------------------------------------"
  puts "\n-----------------------------------------------------------------"
end