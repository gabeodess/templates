# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  # filter_parameter_logging :password
  before_filter :my_basic_auth, :redirect_no_www

  # =============
  # = Protected =
  # =============
  protected
  def login_required
    unless logged_in?
      session[:return_to] = request.path
      redirect_to :login, :notice => 'Please log in.'
    end
  end
  
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
  
  def logged_in?
	 !current_user.nil?
	end
	
	def raise_404(message)
	  raise ActiveRecord::RecordNotFound.new(message)
	end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end
	
end
