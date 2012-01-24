class Phenomenal::Relationship
  attr_accessor :source,:target,:manager
  
  def initialize(source,target)
    @source=source
    @target=target
    @manager=Phenomenal::Manager.instance
    refresh
  end
  
  def ==(other)
    self.class==other.class && 
    self.source==other.source && 
    self.target==other.target
  end
  
  def refresh
    s = manager.context_defined?(source)
    self.source=s if !s.nil?
    
    t = manager.context_defined?(target)
    self.target=t if !t.nil?
  end
  
  def deactivate_context(context)
  end
  
  def activate_context(context)
  end
  
  def deactivate_feature
  end
  
  def activate_feature
  end
  
  def to_s
    "#{self.class.name} between #{source.class.name}:#{source} and #{target.class.name}:#{target}"
  end
end
