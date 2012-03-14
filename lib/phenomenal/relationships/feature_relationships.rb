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
  def add_relationship(source,targets,type)
    targets[:on]=Array.new.push(targets[:on]) if !targets[:on].is_a?(Array)
    if targets[:on].nil?
      Phenomenal::Logger.instance.error(
        "Invalid relationship, missing target context"
      )
    end
    targets[:on].each do |target|      
      r = type.new(source,target,self)
      if relationships.find{|o| o==r}.nil?
        relationships.push(r)
        if self.active?
          r.refresh
          manager.rmanager.relationships.add(r)
          r.activate_feature 
        end
      end
    end
  end
end
