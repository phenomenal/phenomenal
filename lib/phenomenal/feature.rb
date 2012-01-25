class Phenomenal::Feature < Phenomenal::Context
  include Phenomenal::FeatureRelationships

  def initialize(name=nil,manager=nil)
    super(name,manager)
    initialize_relationships
  end
end
