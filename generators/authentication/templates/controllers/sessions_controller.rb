class <%= controller_name.camelcase %>Controller < ApplicationController
  def new
  end

  def create
    <%= user_name.underscore %> = User.authenticate(params[:email], params[:password])
    if <%= user_name.underscore %>
      session[:<%= user_name.underscore %>_id] = <%= user_name.underscore %>.id
      redirect_to :root, :notice => "Logged in!"
    else
      flash.now.alert = "Invalid login or password"
      render "new"
    end
  end

  def destroy
    session[:<%= user_name.underscore %>_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end
