class SortablesController < ApplicationController
  
  # ===========
  # = Example =
  # ===========
  # $('tbody').sortable({
  #   stop:function(){
  #     var uri = "<%= sortable_path('Size') %>?" + $('tbody').sortable('serialize');
  #     $.ajax({
  #       url:uri,
  #       data:{_method:'put'},
  #       type:'post'
  #     })
  #   }
  # });
	
  
  def update
    class_name = params[:id]
    params[class_name.downcase].each_with_index do |id, i|
      class_name.camelcase.constantize.update_all({:position => i + 1}, {:id => id})
    end
    
    render :nothing => true
  end

end
