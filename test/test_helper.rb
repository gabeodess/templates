ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...
  # =========
  # = Units =
  # =========
  
  # ===============
  # = Functionals =
  # ===============
  def get_404(*args)
    begin
      get(*args)
      assert_response 404, "Record was found."
    rescue ActiveRecord::RecordNotFound => e
      assert e.class == ActiveRecord::RecordNotFound, e.inspect
    end
  end

  def get_permission_denied(*args)
    get(*args)
    assert_response 403
  end
    
  def method_missing(*args)
    uri = args[1]
    params = args[2] || {}
    session_options = args[3] || {}
    
    case args[0].to_s
    when /^(get|put|post|delete)_permission_denied$/
      http_method = args[0].to_s.gsub(/_permission_denied$/, '')
      do_permission_denied(http_method, uri, params, session_options)
    when /^(get|put|post|delete)_login_required$/
      http_method = args[0].to_s.gsub(/_login_required$/, '')
      do_login_required(http_method, uri, params, session_options)
    when /^get_redirect_to_\w+$/
      template = args[0].to_s.gsub(/^get_redirect_to_/, '')
      get_template_via_redirect(args[1], template)
    when /^(get|put|post|delete)_/
      http_method = args[0].to_s.match(/^(get|put|post|delete)/)
      template = args[0].to_s.gsub(/^get_/, '')
      uri ||= template
      do_template(http_method, template, uri, params, session_options)
    else
      super
    end
  end
  
  def get_template(template, uri, params, session_options)
    get_ok(uri, params, session_options)
    assert_template template
  end
  
  def do_template(http_method, template, uri, params, session_options)
    do_ok(http_method, uri, params, session_options)
    assert_template template
  end
    
  def do_login_required(http_method, uri, params = {}, session_options = {})
    send(http_method, uri, params, session_options)
    assert @response.redirect_url.match(log_in_url), @response.redirect_url
    assert flash[:notice]
  end

  def do_permission_denied(http_method, uri, params = {}, session_options = {})
    send(http_method, uri, params, session_options)
    assert_response 403
  end
  
  def get_ok(uri, params = {}, session_options = {})
    get uri, params, session_options
    assert_response :ok, session.inspect
  end

  def do_ok(http_method, uri, params = {}, session_options = {})
    send http_method, uri, params, session_options
    assert_response :ok, session.inspect
  end
  
  def get_template_via_redirect(uri, template)
    get_redirect(uri)
    redirected_to = @response.instance_variable_get("@redirected_to")
    new_uri = redirected_to.gsub(/^\w+:\/\/[\w\.]+\//, '')
    get_ok(new_uri)
    assert_template template
  end
  
end
