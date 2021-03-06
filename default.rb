# => rails new app_name -m templates/default.rb

def copy_directory(source_path, destination_path)
  `mkdir #{destination_path}` unless File.directory?(destination_path)
  `cp -R #{source_path} #{destination_path}`
end

def generator(path)
  generators_path = "lib/generators"
  Dir.mkdir(generators_path) unless File.directory?(generators_path)
  copy_directory(path, "lib/generators/#{path.match(/[a-zA-Z]+$/)}")
end

def rvm(command)
  run [@rvmrc, command].join(' && ')
end

@todos ||= []

@gemset = ask("What would you like your gemset to be called?")
@ruby_version = "1.9.3-p0"
@rvmrc = "rvm use --create #{@ruby_version}@#{@gemset}"
file ".rvmrc", @rvmrc
# run @rvmrc
# rvm "gem install bundler"

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
# file "app/assets/stylesheets/application.css", open("../templates/stylesheets/application.css").read
run "cat ../templates/stylesheets/application.css >> app/assets/stylesheets/application.css"
file "app/assets/stylesheets/gallery.css", open('../templates/stylesheets/gallery.css').read
file "app/assets/stylesheets/overlay.css", open('../templates/stylesheets/overlay.css').read
file "app/assets/stylesheets/validation.css", open('../templates/stylesheets/validation.css').read
file "app/assets/stylesheets/dataTables.css", open('../templates/stylesheets/dataTables.css').read


# ===============
# = JAVASCRIPTS =
# ===============
copy_directory "../templates/javascripts/*", "app/assets/javascripts"

# ========
# = ERBs =
# ========
File.delete("app/views/layouts/application.html.erb")
file "app/views/layouts/application.html.erb", open('../templates/layouts/application.html.erb').read

# ===============
# = CONTROLLERS =
# ===============
File.open("app/controllers/application_controller.rb", 'w'){ 
  |f| f.write(File.read(File.expand_path('../controllers/application_controller.rb', __FILE__))) 
}
generate :controller, "home index"

# ===========
# = HELPERS =
# ===========
File.delete("app/helpers/application_helper.rb")
file "app/helpers/application_helper.rb", open('../templates/helpers/application_helper.rb').read
file "app/helpers/nav_helper.rb", open('../templates/helpers/nav_helper.rb').read

# ==========
# = IMAGES =
# ==========
copy_directory "../templates/images/*", "app/assets/images"

# ================
# = INITIALIZERS =
# ================
File.open("config/initializers/mime_types.rb", 'a'){ |f| f.puts(
  File.read(File.expand_path("../initializers/mime_types.rb", __FILE__))
) }
# initializer('mime_types.rb'){ open('../templates/initializers/mime_types.rb').read  }
initializer('mime_types.txt'){ open('../templates/initializers/mime_types.txt').read  }
# initializer('fields_with_errors.rb'){ open('../templates/initializers/fields_with_errors.rb').read  }
initializer('string.rb'){ open('../templates/initializers/string.rb').read  }
initializer('datetime_formats.rb'){ open('../templates/initializers/datetime_formats.rb').read  }

# ==============
# = Generators =
# ==============
generator(File.expand_path("../generators/nifty", __FILE__))
file("lib/generators/nifty.rb", File.read(File.expand_path("../generators/nifty.rb", __FILE__)))

# ===========
# = PLUGINS =
# ===========
gem "will_paginate", "3.0.2"
gem "meta_search"
gem 'factory_girl_rails', :group => [:test]
gem 'guard-spork', :group => [:test]
gem 'guard-test', :group => [:test]

if yes?('Do you want to use Paperclip?')
  gem "paperclip", '>= 2.3.3', :git => "http://github.com/thoughtbot/paperclip.git"
  initializer('paperclip.rb'){ open('../templates/initializers/paperclip.rb').read  }
  file 'app/helpers/paperclip_helper.rb', open('../templates/helpers/paperclip_helper.rb').read
  run 'cp ../templates/controllers/paperclip_controller.rb app/controllers/paperclip_controller.rb'
  route "delete '/paperclip/:class_name/:id/:attachment' => 'paperclip#destroy', :as => 'paperclip'"
end

if auth = yes?("Do you want to use user authentication?")
  
  name = ask("What do you want a user to be called?")
  
  generator(File.expand_path("../generators/authentication", __FILE__))
  
  rvm "bundle install"
  generate :authentication, "#{name} sessions"
  
  if yes?("Do you want to use declarative authorization?")
    gem "declarative_authorization", :git => "git://github.com/stffn/declarative_authorization.git"
    file "app/helpers/declarative_authorization_helper.rb", File.read('../templates/helpers/declarative_authorization_helper.rb')
    file "config/authorization_rules.rb", File.read("../templates/config/authorization_rules.rb")
  end
end

if yes?('Would you like to set up gmail as your mail server?')
  run 'cp ../templates/initializers/gmail_config.rb config/initializers/gmail_config.rb'
  @todos << "Edit config/initializers/gmail_config.rb to contain your gmail credentials."
end

if yes?('Would you like to set up PayPal as your payments gateway?')
  run "cp ../helpers/paypal_helper.rb app/helpers/paypal_helper.rb"

  generate :scaffold, 'PaymentNotification params:text transaction_id:string status:string payer_email:string payment_gross:float invalid_secret:boolean'
  generate :scaffold, 'LineItem product_id:integer quantity:integer unit_price:decimal'

  file "config/paypal_config.yml", open('../config/paypal_config.yml').read
  file "config/initializers/load_paypal_config.rb", open('../initializers/load_paypal_config.rb').read
  file "certs/README.rdoc", open('../readmes/cert_readme.txt').read

  @todos ||= []
  @todos << "Edit config/paypal_config.yml to contain your paypal credentials."
  @todos << "Copy your paypal certificates to the 'certs' directory."
end

route "root :to => 'home#index'"
run 'rm public/index.html'

gitignore = <<-END
.DS_Store
public/system/*
END
File.open(".gitignore", "a"){ |f| f.puts gitignore } 

run "cp config/database.yml config/example_database.yml"
# rvm "bundle install"
# run "rake db:migrate"

# git :init
# git :add => "."
# git :commit => "-a -m 'initial commit'"
@todos << 'Run: bundle install'
@todos << 'Run: rake db:migrate'

unless @todos.blank?
  puts "\n\n-----------------------------------------------------------------"
  puts "Your Ruby on Rails application has been created.\nTo get it up and running please complete the items listed below."
  puts "-----------------------------------------------------------------\n\n"
  puts @todos.map{|item| "\t=> #{item}\n\n"}.join
  puts "\n-----------------------------------------------------------------"
  puts "\n-----------------------------------------------------------------"
end