# Define the methods that can be called by a feature to
# define relationships
module Phenomenal::FeatureRelationships 
  attr_accessor :relationships
  
  def initialize_relationships
    @relationships = Array.new
  end
  
  def requirements_for(source,targets)
    add_relationship(source,targets,Phenomenal::Requirement)
  end  
  alias_method :phen_requirements_for,:requirements_for
  
  def implications_for(source,targets)
    add_relationship(source,targets,Phenomenal::Implication)
  end  
  alias_method :phen_implications_for,:implications_for
  
  def suggestions_for(source,targets)
    add_relationship(source,targets,Phenomenal::Suggestion)
  end  
  alias_method :phen_suggestions_for,:suggestions_for
  
  private 
  # Create the new relationships and add them to the runtime system
  def add_relationship(source,targets,type)
    targets[:on]=Array.new.push(targets[:on]) if !targets[:on].is_a?(Array)
    if targets[:on].nil?
      raise(Phenomenal::Error,
        "Invalid relationship, missing target context"
      )
    end
    targets[:on].each do |target|      
      r = type.new(source,target,self)
      if relationships.find{|o| o==r}.nil?
        relationships.push(r)
        set_relationship(r)
      end
    end
  end
  
  # Refresh the references (replace symbol by actual object reference)
  # And activate the relationship if the associated feature is already active
  def set_relationship(relationship)
    if self.active?
      relationship.refresh
      manager.rmanager.relationships.add(relationship)
      relationship.activate_feature 
    end
  end
end
