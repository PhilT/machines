module Machines
  class Base
    files = Dir[File.join($conf.application_dir, 'machines/**/*.rb')]
    files.reject!{|name| File.basename(name) == 'base.rb' }
    files.sort.each do |lib|
      require lib
      path = ActiveSupport::Inflector.camelize(File.basename(lib, '.rb'))
      module_or_class = eval(path, nil, "eval: #{path}") rescue nil
      include module_or_class unless module_or_class.nil? || module_or_class.is_a?(Class)
    end
  end
end

