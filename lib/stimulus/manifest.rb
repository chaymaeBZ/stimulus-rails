module Stimulus::Manifest
  extend self

  def generate_from(controllers_path)
    manifest = extract_controllers_from(controllers_path).collect do |controller_path|
      import_and_register_controller(controllers_path, controller_path)
    end

    manifest.uniq
  end

  def import_and_register_controller(controllers_path, controller_path)
    controller_path = controller_path.relative_path_from(controllers_path).to_s
    module_path = controller_path.split('.').first
    controller_class_name = module_path.underscore.camelize.gsub(/::/, "__")
    tag_name = module_path.remove(/_controller/).tr("_", "-").gsub(/\//, "--")

    <<-JS

import #{controller_class_name} from "./#{module_path}"
application.register("#{tag_name}", #{controller_class_name})
    JS
  end

  def extract_controllers_from(directory)
    (directory.children.select { |e| e.to_s =~ /_controller(\.\w+)+$/ } +
      directory.children.select(&:directory?).collect { |d| extract_controllers_from(d) }
    ).flatten.sort
  end
end
