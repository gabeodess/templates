# Paperclip.options[:command_path] = '/opt/local/bin' if Rails.env.development?

# encoding: utf-8
module Paperclip
  # The Attachment class manages the files for a given attachment. It saves
  # when the model saves, deletes when the model is destroyed, and processes
  # the file upon assignment.
  class Attachment

    def width(style = default_style)
      Paperclip::Geometry.from_file(to_file(style)).width if image?
    end

    def height(style = default_style)
      Paperclip::Geometry.from_file(to_file(style)).height if image?
    end

    def image?(style = default_style)
      # content_type
      IMAGE_TYPES.include?(content_type)# and content_type != 'image/gif'
    end
  end
end

PAPERCLIP_URL = "paperclip/:class/:attachment/:id/:style/:filename.:extension"
PAPERCLIP_SETTINGS = {
  :path => Rails.root.join('public', PAPERCLIP_URL),
  :url => PAPERCLIP_URL,
  :convert_options => { :all => '-strip -colorspace RGB'}
}
PAPERCLIP_SETTINGS.merge!{
  :storage => :s3,
  :bucket => CONFIG['s3_bucket']
} unless CONFIG['s3_bucket'].blank?