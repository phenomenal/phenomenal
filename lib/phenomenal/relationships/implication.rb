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
      activation_counter+=1
    end
  end
  
  def deactivate_feature
    if activation_counter>0
      target.deactivate
      activation_coutner-=1
    end
  end
  
  def activate_context(context)
    if source==context
      target.activate
    end
  end
  
  def deactivate_context(context)
    if source==context
      target.deactivate
    else
      source.deactivate
    end
  end
end
