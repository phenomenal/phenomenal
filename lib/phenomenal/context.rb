# Represent a first class context
class Phenomenal::Context
  @@total_activations = 0
   
  attr_accessor :activation_age, :activation_frequency, :priority, :adaptations, 
    :activation_count
  attr_reader :manager,:name
  
  def initialize(name=nil, priority=nil,manager=nil)
    @manager=manager || Phenomenal::Manager.instance
    @name = name
    @priority = priority
    @activation_age = 0
    @activation_count = 0
    @adaptations = Array.new
    @manager.register_context(self)
  end
  
  # Unregister the context from the context manager,
  # This context shoudn't be used after.
  # The context has to be inactive before being forgetted
  # TODO Find a way to avoid the use of forgeted context (use forgeted flag?)
  def forget
    if active?
      Phenomenal::Logger.instance.error(
        "Active context cannot be forgotten"
      )
    else
      manager.unregister_context(self)
    end
  end
  
  # Add a new method adaptation to the context
  # Return the adaptation just created
  def add_adaptation(klass, method_name,umeth=nil, &implementation)
    if umeth
      implementation = umeth
    end
    if adaptations.find{ |i| i.concern?(klass,method_name) }
      Phenomenal::Logger.instance.error(
        "Error: Illegal duplicated adaptation in context: #{self} for " + 
        "#{klass.name}:#{method_name}"
      )
    else
      if klass.instance_methods.include?(method_name)
        method = klass.instance_method(method_name)
      elsif klass.methods.include?(method_name)
        method = klass.method(method_name)
      else
        Phenomenal::Logger.instance.error(
          "Error: Illegal adaptation for context #{self},a method with "+
          "name: #{method_name} should exist in class #{klass.name} to "+ 
          "be adapted"
        )
      end
      if method.arity != implementation.arity
        Phenomenal::Logger.instance.error(
          "Error: Illegal adaptation for context #{self},the adaptation "+ 
          "have to keep the original method arity for method: " +
          "#{klass.name}.#{method_name}: (#{method.arity} instead of " +
          "#{implementation.arity})" 
        )
      end
      
      adaptation = Phenomenal::Adaptation.new(
        self, klass, method_name, implementation
      )
      adaptations.push(adaptation)
      manager.register_adaptation(adaptation)
      adaptation
    end
  end

  # Remove a method adaptation from the context
  def remove_adaptation(klass,method_name)
    adaptation_index =
      adaptations.find_index{ |i| i.concern?(klass, method_name) }
    if !adaptation_index
      Phenomenal::Logger.instance.error(
        "Error: Illegal deleting of an inexistent adaptation in context: " +
        "#{self} for #{klass.name}.#{method_name})"
      )
    end
    
    adaptation = adaptations.delete_at(adaptation_index)
    manager.unregister_adaptation(adaptation)
  end
  
  # Activate the context
  def activate
    @@total_activations = @@total_activations+1
    self.activation_age = @@total_activations
    self.activation_count = self.activation_count+1
    manager.activate_context(self)
    self
  end
  
  # Deactivate the context
  def deactivate
    was_active = active?
    if self.activation_count>0
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
  
  # Return the activation age of the context:
  #  The age counter minus the age counter when the context was activated
  #  for the last time
  def age
    if activation_age == 0
      @@total_activations
    else
      @@total_activations-activation_age
    end
  end
  
  # Return context informations:
  #   - Name
  #   - List of the adaptations
  #   - Active state
  #   - Activation age
  def informations
    {
      :name=>name,
      :adaptations=>adaptations,
      :active=>active?,
      :activation_age=>age
    }
  end
  
  # String representation of the context
  def to_s
    if name
      name.to_s
    else
      "Anonymous context"
    end
  end
end
