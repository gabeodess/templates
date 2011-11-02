class SortablesGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  def copy_controller
    copy_file 'controller.rb', 'app/controllers/sortables_controller.rb'
  end
  
  def generate_route
    route %{resources :sortables, :only => [:update]}
  end
end
