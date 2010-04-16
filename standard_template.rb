# => rails app_name -m templates/base_template.rb

@todos ||= []

run "echo TODO > README"

# =======
# = LIB =
# =======
lib "validator.rb", <<-CODE
class Validator
  cattr_accessor :login_regex, :bad_login_message, :name_regex, :bad_name_message, :zip_code_regex, :email_name_regex, :domain_head_regex, :domain_tld_regex, :email_regex, :bad_email_message, :currency_regex

  self.login_regex       = /\A\w[\w\.\-_@]+\z/                     # ASCII, strict
  # self.login_regex       = /\A[[:alnum:]][[:alnum:]\.\-_@]+\z/     # Unicode, strict
  # self.login_regex       = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive

  self.bad_login_message = "use only letters, numbers, and .-_@ please.".freeze

  self.name_regex        = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
  self.bad_name_message  = "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze

  # self.email_name_regex  = '[\w\.%\+\-]+'.freeze
  self.domain_head_regex = '(?:[A-Z0-9\-]+\.)+'.freeze
  self.domain_tld_regex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  self.email_regex       = /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
  self.bad_email_message = "should look like an email address.".freeze
  
  self.zip_code_regex = /^\d{5}([\-]\d{4})?$/
  self.currency_regex = /^\$[\d,]+$|^\$[\d,]+\.\d$|^\$\.\d+$|^[\d,]+$|^[\d,]+\.\d+$|^\.\d+$/
  
end
CODE

# =================
# = CONFIGURATION =
# =================
config "config.yml", <<-YAML
development:
  perform_authentication: false
  username: admin
  password: password
  shared_secret: 54044f74e079260c1df19ef174f4247f

test:
  perform_authentication: false

production:
  perform_authentication: true
  username: admin
  password: password
  shared_secret: 54044f74e079260c1df19ef174f4247f
YAML
initializer "load_config.rb", <<-RUBY
APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]
RUBY

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
run "cp -r ../templates/javascripts/* public/javascripts"

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
  run 'cp ../templates/controllers/paperclip_controller.rb app/controllers/paperclip_controller.rb'
  route "map.paperclip '/paperclip/:class_name/:id/:attachment', :controller => 'paperclip', :action => 'destroy', :method => :delete"
end

if auth = yes?("Do you want to use Restful Authentication?")
  plugin "restful_authentication", :git => "git://github.com/technoweenie/restful-authentication.git"
  name = ask("What do you want a user to be called?")
  generate :authenticated, "#{name} sessions"
  
  if yes?("Do you want to use declarative authorization?")
    plugin "declarative_authorization", :git => "git://github.com/stffn/declarative_authorization.git"
    file "app/helpers/declarative_authorization_helper.rb", open('../templates/helpers/declarative_authorization_helper.rb').read
    run "cp ../templates/config/authorization_rules.rb app/config/"
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
public/system/*
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