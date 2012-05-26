# Define the behavior of the Implication relationship
class Phenomenal::Implication < Phenomenal::Relationship  
  attr_accessor :activation_counter
  def initialize(source,target,feature)
    super(source,target,feature)
    @activation_counter=0
  end
  
  def activate_feature
    if source.active?
      target.activate
      self.activation_counter+=1
    end
  end
  
  def deactivate_feature
    if activation_counter>0
      target.deactivate
      self.activation_counter-=1
    end
  end
  
  def activate_context(context)
    if source==context
      target.activate
      self.activation_counter+=1
    end
  end
  
  def deactivate_context(context)
    if source==context && activation_counter>0
      target.deactivate
      self.activation_counter-=1
    elsif activation_counter>0
      source.deactivate
      self.activation_counter-=1
    else
      # Nothing to do
    end
  end
end
