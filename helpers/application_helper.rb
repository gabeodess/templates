# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def strip_and_format(text)
    return simple_format(strip_tags(text))
  end
  
  def cname
    controller.controller_name
  end
  
  def aname
    controller.action_name
  end
  
  def link_to_external(text, url, options = {})
    link_to text, 'http://' + url.gsub(/^\w+:/,''), options.merge(:popup => true)
  end
  
  def external_url(url, options = {})
    protocol = options[:protocol].try(:to_s).blank? || 'http'
    "#{protocol}://" + url.gsub(/^\w+:/,'')
  end
  
end
