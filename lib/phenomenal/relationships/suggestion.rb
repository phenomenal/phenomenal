class Phenomenal::Suggestion < Phenomenal::Relationship
  attr_accessor :activation_counter
  
  def initialize(source,target,feature)
    super(source,target,feature)
    @activation_counter=0
  end
  
  def activate_feature
    begin
      if source.active?
        target.activate
        self.activation_counter+=1
      end
    rescue
    end
  end
  
  def deactivate_feature
    begin
      if activation_counter>0
        target.deactivate
        self.activation_coutner-=1
      end
    rescue
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
    end
  end
end
