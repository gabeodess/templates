class <%= user_name.camelcase.pluralize %>Controller < ApplicationController
  def new
    @<%= user_name.underscore %> = <%= user_name.camelcase %>.new
  end

  def create
    @<%= user_name.underscore %> = User.new(params[:<%= user_name.underscore %>])
    if @<%= user_name.underscore %>.save
      session[:<%= user_name.underscore %>_id] = @<%= user_name.underscore %>.id unless logged_in?
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new"
    end
  end

end
