# Represents a first class context
class Phenomenal::Context
  extend Phenomenal::ContextCreation
  include Phenomenal::ContextRelationships
  
  @@total_activations = 0
  
  attr_accessor :activation_age, :activation_frequency, :adaptations, 
    :activation_count, :parent, :forgotten
  attr_reader :manager,:name, :priority  
  # Instance methods
  def initialize(name=nil, manager=nil)
    @manager = manager || Phenomenal::Manager.instance
    @name = name
    @activation_age = 0
    @activation_count = 0
    @adaptations = Array.new
    @manager.register_context(self)
    @parent=nil
    @forgotten=false
    @priority=nil
  end
  
  # Unregister the context from the context manager,
  # This context shouldn't be used after.
  # The context has to be inactive before being forgetted
  # TODO handle relationships references
  def forget
    if active?
      raise(Phenomenal::Error,
        "Active context cannot be forgotten"
      )
    else
      manager.unregister_context(self)
      self.forgotten=true
      nil
    end
  end
  
  # Add a new method adaptation to the context
  # Return the adaptation just created
  def add_adaptation(klass, method_name,instance,umeth=nil, &implementation)
    if klass.nil? # Not defined class
      raise(Phenomenal::Error,
        "The class to be adapted wasn't specified. Don't forget to use 'adaptations_for(Klass)' before adapting a method"
      )
    end
    if adaptations.find{ |i| i.concern?(klass,method_name,instance) }
     raise(Phenomenal::Error,
        "Illegal duplicated adaptation in context: #{self} for " + 
        "#{klass.name}:#{method_name}."
      )
    else
      adaptation = Phenomenal::Adaptation.new(
        self, klass, method_name,instance, umeth||implementation
      )
      adaptations.push(adaptation)
      manager.register_adaptation(adaptation)
      adaptation
    end
  end
  
  # Catch nested context calls and transform them in nested contexts creation
  def context(context,*contexts,&block)
    check_validity
    Phenomenal::Context.create(true,self,self,context,*contexts,&block)
  end
  alias_method :phen_context,:context
  
  # Catch nested feature calls and transform them in nested contexts creation
  def feature(feature,*features, &block)
    check_validity
    Phenomenal::Feature.create(true,self,self,feature,*features,&block)
  end
  alias_method :phen_feature,:feature

  # Add multiple adaptations at definition time
  def add_adaptations(&block)
    instance_eval(&block) if block
    @current_adapted_class=nil #Reset adapted class after context closed
    nil
  end
  
  # Set the current adapted class for the next adapt calls
  def adaptations_for(klass)
    @current_adapted_class = klass
  end
  
  # Adapt a method for @current_adapted_class
  def adapt(method,&block)
    add_adaptation(@current_adapted_class,method,true,&block)
  end
  
  # Adapt a class method for @current_adapted_class
  def adapt_class(method,&block)
    add_adaptation(@current_adapted_class,method,false,&block)
  end

  # Remove a method adaptation from the context
  def remove_adaptation(klass,method_name,instance)
    adaptation_index =
      adaptations.find_index{ |i| i.concern?(klass, method_name,instance) }
    if !adaptation_index
      raise(Phenomenal::Error,
        "Illegal deleting of an inexistent adaptation in context: " +
        "#{self} for #{klass.name}.#{method_name})."
      )
    end
    
    adaptation = adaptations.delete_at(adaptation_index)
    manager.unregister_adaptation(adaptation)
    adaptation
  end
  
  # Activate the context
  def activate
    check_validity
    @@total_activations +=1
    self.activation_age =@@total_activations
    self.activation_count = self.activation_count+1
    manager.activate_context(self)
    self
  end  
  
  # Deactivate the context
  def deactivate
    check_validity
    was_active = active?
    if self.activation_count>0
      #Deactivation
      self.activation_count =  self.activation_count-1
    end
    if was_active && !active?
      manager.deactivate_context(self)
    end
    self
  end
  
  # True if the context is active
  def active?
    activation_count>0
  end
  
  # True if the context has just became active
  def just_activated?
    activation_count==1
  end
  
  # True if the context is anonymous
  def anonymous?
    name.nil?
  end
  
  # Return the activation age of the context:
  # (The age counter minus the age counter when the context was activated
  # for the last time)
  def age
    @@total_activations-activation_age
  end
  
  # Return context informations:
  # - Name
  # - List of the adaptations
  # - Active state
  # - Activation age
  # - Activation count
  def information
    {
      :name=>name,
      :adaptations=>adaptations,
      :active=>active?,
      :age=>age,
      :activation_count=>activation_count,
      :type=>self.class.name
    }
  end
  
  # Return the closest parent feature of the context
  def parent_feature
    p = parent
    while p!=nil && !p.is_a?(Phenomenal::Feature) do
      p=p.parent
    end
    if p.nil?
      manager.default_feature
    else
      p
    end
  end
  
  # String representation of the context
  def to_s
    if name
      name.to_s
    elsif self==manager.default_feature
      "Default feature"
    elsif manager.combined_contexts[self]
       "#{manager.combined_contexts[self].flatten}"
    else
      "Anonymous context"
    end
  end
  
  def priority=(priority)
    @priority=priority
    return unless manager.shared_contexts[self]
    manager.shared_contexts[self].each do |shared_context|
      shared_context.priority=[priority,shared_context.priority].compact.min
    end
  end
  private
  def check_validity
    if forgotten
      raise(Phenomenal::Error,
        "Action not allowed anymore when context has been forgotten."
      )
    end
  end
end
