# Define a first class relationship
class Phenomenal::Relationship
  attr_accessor :source,:target,:manager,:feature
  
  def initialize(source,target,feature)
    @source=source
    @target=target
    @manager=Phenomenal::Manager.instance
    @feature=feature
    refresh
  end
  
  def ==(other)
    self.class==other.class && 
    self.source==other.source && 
    self.target==other.target &&
    self.feature==other.feature
  end
  
  def refresh
    s = manager.context_defined?(source)
    self.source=s if !s.nil?
    
    t = manager.context_defined?(target)
    self.target=t if !t.nil?
  end
  
  # Must be redifined for each type of relation
  # if necessary
  # Called when a context is activated
  def activate_context(context)
  end
  
  # Must be redifined for each type of relation
  # if necessary
  # Called when a context is deactivated
  def deactivate_context(context)
  end
  
  # Must be redifined for each type of relation
  # if necessary
  # Called when a feature is activated
  def activate_feature
  end
  
  # Must be redifined for each type of relation
  # if necessary
  # Called when a feature is deactivated
  def deactivate_feature
  end

  def to_s
    "#{self.class.name} between #{source.class.name}:#{source} and #{target.class.name}:#{target}"
  end
end
