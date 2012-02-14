require 'singleton'
# This class manage the different relatiohsips in the system between contexts
class Phenomenal::RelationshipsManager
  include Singleton
  
  attr_accessor :relationships
  
  def activate_relationships(context)
    # Step 1: Import the new relationships for a feature
    if context.is_a?(Phenomenal::Feature)
      import_relationships(context)
    end
    # Step 2: Apply relationships
    relationships.get_for(context).each do |relationship|
      relationship.activate_context(context)
    end
  end
  
  def deactivate_relationships(context)
    # Step 1: Unapply relationships
    relationships.get_for(context).each do |relationship|
      relationship.deactivate_context(context)
    end
    # Step 2: Remove relationships
    if context.is_a?(Phenomenal::Feature)
      remove_relationships(context)
    end
  end
  
  # Called when a context is defined in the manager
  def update_relationships_references(context)
    relationships.update_references(context)
  end
  
  private
  def import_relationships(feature)
    begin
      feature.relationships.each do |relationship|
        relationship.refresh # Update references
        relationship.activate_feature # Activate relationship
        relationships.add(relationship)
      end
    rescue Phenomenal::Error => m
      feature.deactivate
      Phenomenal::Logger.instance.debug(
        "Unable to activate the feature #{feature} \n #{m}"
      )
    end
  end
  
  def remove_relationships(feature)
    feature.relationships.each do |relationship|
      if relationships.include?(relationship)
        relationship.deactivate_feature
        relationships.remove(relationship)
      end
    end
  end
  
  def initialize
    @relationships = Phenomenal::RelationshipsStore.new
  end
end
