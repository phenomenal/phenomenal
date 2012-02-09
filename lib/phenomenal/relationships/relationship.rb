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
  
  def activate_context(context)
  end
  
  def deactivate_context(context)
  end
  
  def activate_feature
  end
  
  def deactivate_feature
  end

  def to_s
    "#{self.class.name} between #{source.class.name}:#{source} and #{target.class.name}:#{target}"
  end
end
