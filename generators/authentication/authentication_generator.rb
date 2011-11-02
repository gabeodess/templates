class AuthenticationGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :user_name, :type => :string, :default => 'user'
  argument :controller_name, :type => :string, :default => 'sessions'
  class_option :skip_migration, :type => :boolean, :default => false, :desc => "Skip migration file."
  
  def generate_templates
    template 'models/user.rb', "app/models/#{user_name.underscore}.rb"
    template 'migrate/create_user.rb', "db/migrate/#{Time.now.to_s(:number)}_create_#{user_name.underscore.pluralize}.rb" unless options.skip_migration?
    template 'controllers/users_controller.rb', "app/controllers/#{user_name.underscore.pluralize}_controller.rb"
    template 'controllers/sessions_controller.rb', "app/controllers/#{controller_name.underscore}_controller.rb"
    template 'views/users/new.html.erb', "app/views/#{user_name.underscore.pluralize}/new.html.erb"
    template 'views/sessions/new.html.erb', "app/views/#{controller_name.underscore}/new.html.erb"
  end
  
  def link_gems
    gem 'bcrypt-ruby', :require => 'bcrypt'
  end
  
  def generate_routes
    path = Rails.root.join('config/routes.rb')
    doc = File.open(path).read
    doc = doc.split("\n")
    start_index = nil
    doc.each_with_index{ |item, i| start_index = i and break if item.match("Application.routes.draw do") }
    routes = <<-RUBY
    get "logout" => "sessions#destroy", :as => "logout"
    get "login" => "sessions#new", :as => "login"
    get "signup" => "users#new", :as => "signup"
    root :to => "users#new"
    resources :users
    resources :sessions
    RUBY
    
    new_doc = (doc[0..start_index] << routes) + doc[(start_index + 1)..-1]
    File.open(path, 'w'){ |f| f.write new_doc.join("\n") }
  end
  
  def update_application_controller
    path = Rails.root.join('app/controllers/application_controller.rb')
    doc = File.open(path).read
    doc = doc.split("\n")
    start_index = nil
    doc.each_with_index{ |item, i| start_index = i and break if item.match("class ApplicationController") }
    new_doc = doc[0..start_index] 
    new_doc << "\thelper_method :current_user" unless File.read(path).include?("helper_method :current_user")
    new_doc = new_doc + doc[(start_index + 1)..-1]

    end_index = nil
    new_doc.each_with_index{ |item, i| start_index = i and break if item.match("class ApplicationController") }
    private_exists = nil
    i = new_doc.length - 1
    while i > 0
      private_exists = true and end_index = i and break if new_doc[i].gsub(/[ \t\n\r]/, "") == "private"
      i = i - 1
    end
    unless end_index
      i = new_doc.length - 1
      while i > 0
        end_index = i and break if new_doc[i].gsub(" ", "") == "end"
        i = i - 1
      end
    end
    final_doc = new_doc[0..(end_index - 1)]
    final_doc << "\tprivate" unless private_exists
    current_user = <<-RUBY

  def current_user
    @current_user ||= #{user_name.camelcase}.find(session[:#{user_name.downcase}_id]) if session[:#{user_name.downcase}_id]
  end
    RUBY
    
    final_doc << current_user unless File.read(path).include?(current_user)
    final_doc = final_doc + new_doc[(end_index)..-1]
    File.open(path, 'w'){ |f| f.write final_doc.join("\n") }
  end
end
