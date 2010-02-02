require "smtp_tls"

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :tls => true,
    :address => "smtp.gmail.com",
    :port => "587",
    :domain => "yourdomain.com",
    :authentication => :plain,
    :user_name => "you@gmail.com",
    :password => "your_gmail_password" 
  }