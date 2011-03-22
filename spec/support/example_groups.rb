require 'active_support'

module IntegrationExampleGroup
  extend ActiveSupport::Concern

  included do
    metadata[:type] = :integration
  end

  RSpec.configure {|c| c.include(self, :example_group => { :file_path => /spec\/integration/ })}
end

module UnitExampleGroup
  extend ActiveSupport::Concern

  included do
    metadata[:type] = :unit
  end

  RSpec.configure {|c| c.include(self, :example_group => { :file_path => /spec\/unit/ })}
end

