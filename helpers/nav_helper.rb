module NavHelper
  
  def link_to_active(text, url, args = {}, condition = false)
    args[:class] = "#{args[:class]} active" if [request.url, request.path].include?(url_for(url)) || condition
    link_to(text, url, args)
  end
  
  def link_to_controller(controller, options = {})
    text = options[:as] || controller.to_s.titleize
    link_to_active(text, controller, options, cname == controller.to_s)
  end
  
  def link_to_new(item, options = {})
    text = options.delete(:text) || image_tag('new.png', :alt => "New #{item.to_s.titleize}", :title => "New #{item.to_s.titleize}")
    link_to text, :"new_#{item.to_s}", options
  end
  
  def link_to_edit(item, options = {})
    text = options.delete(:text) || image_tag('edit.jpg', :alt => 'Edit', :title => 'Edit')
    link_to text, send("edit_#{item.class.to_s.tableize.singularize}_path", item), options
  end

  def link_to_show(item, options = {})
    text = options.delete(:text) || image_tag('show.png', :alt => 'Show', :title => 'Show')
    link_to text, item, options
  end
  
  def link_to_destroy(item, options = {})
    text = options.delete(:text) || image_tag('delete.gif', :alt => 'Delete', :title => 'Delete')
    options[:method] = :delete
    options[:confirm] ||= "Are you sure?"
    link_to text, send("edit_#{item.class.to_s.tableize.singularize}_path", item), options
  end
  alias_method :link_to_delete, :link_to_destroy
  
end