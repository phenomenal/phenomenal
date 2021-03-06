# Define the methods that can be called by a context to 
# define relationships
module Phenomenal::ContextRelationships
  def requires(context,*contexts)
    set_context_relationship(context,contexts) do |target|
      self.parent_feature.requirements_for(self,{:on=>target})
    end
  end
  
  def implies(context,*contexts)
    set_context_relationship(context,contexts) do |target|
      self.parent_feature.implications_for(self,{:on=>target})
    end
  end
  
  def suggests(context,*contexts)
    set_context_relationship(context,contexts) do |target|
      self.parent_feature.suggestions_for(self,{:on=>target})
    end
  end
  
  private
  def set_context_relationship(context,contexts)
    contexts = contexts.push(context)
    contexts.each do |target|
      yield(target)
    end
  end
end
