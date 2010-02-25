module PaperclipHelper
  
  def link_to_attachment(attachment, options = {})
    return 'No file.' unless attachment.file?
    style = options.delete(:style) || :original
    link_style = options.delete(:link_style) || style
    display_style = options.delete(:display_style) || style
    use_image = options.delete(:use_image) || true
    options[:popup] ||= true
    text = IMAGE_TYPES.include?(attachment.content_type) && use_image ? image_tag(attachment.url(display_style)) : "Link to #{attachment.original_filename}"
    return link_to(text, attachment.url(link_style), options)
  end
  alias_method :link_to_paperclip, :link_to_attachment
  
end