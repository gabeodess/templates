class SortablesController < ApplicationController
  
  # ===========
  # = Example =
  # ===========
  # $('tbody').sortable({
  #   stop:function(){
  #     var uri = "<%= sort_path %>?" + $('tbody').sortable('serialize');
  #     $.ajax({
  #       url:uri,
  #       data:{_method:'put', class_name:'Size'},
  #       type:'post'
  #     })
  #   }
  # });
	
  
  def update
    class_name = params[:class_name]
    params[class_name].each_with_index do |id, i|
      class_name.camelcase.constantize.update_all({:position => i + 1}, {:id => id})
    end
    
    render :nothing => true
  end

end
