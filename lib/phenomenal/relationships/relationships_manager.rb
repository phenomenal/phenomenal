require 'singleton'

class Phenomenal::RelationshipsManager
  include Singleton
  
  attr_accessor :relationships
  
  def activate_relationships(context)
    # Step 1: Import the new relationships for a feature
    if context.is_a?(Phenomenal::Feature)
      import_relationships(context)
    end
    # Step 2: Apply relationships
    relationships.get_for_source(context).each do |relationship|
      relationship.activate_context(context)
    end
    relationships.get_for_target(context).each do |relationship|
      relationship.activate_context(context)
    end
  end
  
  def deactivate_relationships(context)
    # Step 1: Unapply relationships
    relationships.get_for_source(context).each do |relationship|
      relationship.deactivate_context(context)
    end
    relationships.get_for_target(context).each do |relationship|
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
    feature.relationships.each do |relationship|
      # Update references
      relationship.refresh 
      # Activate relationship
      relationship.activate_feature
    end
    
    # Import
    feature.relationships.each do |relationship|
      relationships.add(relationship)
    end
  end
  
  def remove_relationships(feature)
   feature.relationships.each do |relationship|
      # Deactivate relationship
      relationship.deactivate_feature
    end
    # Remove
    feature.relationships.each do |relationship|
      relationships.remove(relationship)
    end
  end
  
  def initialize
    @relationships = Phenomenal::RelationshipsStore.new
  end
end
