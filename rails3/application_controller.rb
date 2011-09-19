# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :my_basic_auth, :redirect_no_www
    
  protected
    def set_iphone_format
      if is_iphone_request?
        request.format = :iphone
      end
    end
    
    def is_iphone_request?
      request.user_agent =~ /(Mobile\/.+Safari)/
    end
    
    def redirect_no_www      
      if request.host.match(/^www/)
        headers["Status"] = "301 Moved Permanently"
        redirect_to(request.protocol + request.host.gsub(/^www./, '') + request.path)
      end
    end
    
    def my_basic_auth
      if CONFIG['perform_authentication']
        authenticate_or_request_with_http_basic do |username, password|
          username == CONFIG['username'] && password == CONFIG['password']
        end
      end
    end
end
