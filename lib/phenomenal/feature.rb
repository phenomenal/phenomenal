class Phenomenal::Feature < Phenomenal::Context
  
  attr_accessor :relationships
  
  def initialize(name=nil, priority=nil,manager=nil)
    super(name,priority,manager)
    @relationships = Array.new
  end
  
  def feature(feature,*features, &block)
    Phenomenal::Feature.create(self,feature,*features,true,self,&block)
  end
  alias_method :phen_feature,:feature
  
  def requirements_for(source,targets)
    add_relationship(source,targets,Phenomenal::Requirement)
  end
  
  private 
  def add_relationship(source,targets,type)
    targets[:on]=Array.new.push(targets[:on]) if !targets[:on].is_a?(Array)
    #TODO raise error if targets[on] is empty
    targets[:on].each do |target|      
      r = type.new(source,target)
      if relationships.find{|o| o==r}.nil?
        relationships.push(r)
      end
    end
  end
end
