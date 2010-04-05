class SortablesController < ApplicationController
  
  def update
    class_name = params[:class_name]
    params[class_name].each_with_index do |id, i|
      class_name.camelcase.constantize.update_all({:position => i + 1}, {:id => id})
    end
    
    render :nothing => true
  end

end
