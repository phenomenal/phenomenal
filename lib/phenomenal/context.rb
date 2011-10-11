# Represent a first class context
class Phenomenal::Context
  @@total_activations = 0
  #TODO this is needed for context_age in manager
  def self.total_activations
    @@total_activations
  end
   
  attr_accessor :name, :activation_age, :activation_frequency, :priority, :adaptations, :activation_count
  
  def initialize(name, priority=nil)
    @name = name
    @priority = priority
    @activation_age = 0
    @activation_count = 0
    @adaptations = Array.new
  end
  
  # Add a new method adaptation to the context
  # Return the adaptation just created
  def add_adaptation(klass, method_name, implementation)
    if adaptations.find{ |i| i.concern?(klass,method_name) }
      Phenomenal::Logger.instance.error(
        "Error: Illegal duplicated adaptation in context: #{self.name} for " + 
        "#{klass.name}:#{method_name}"
      )
    else
      adaptation = Phenomenal::Adaptation.new(self,klass, method_name,implementation)
      adaptations.push(adaptation)
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
        "#{self.name} for #{klass.name}.#{method_name})"
      )
    end
    adaptations.delete_at(adaptation_index)
  end
  
  # Activate the context
  def activate
    @@total_activations = @@total_activations+1
    self.activation_age = @@total_activations
    self.activation_count = self.activation_count+1
    name
  end
  
  # Deactivate the context
  def deactivate
    if self.activation_count>0
      self.activation_count =  self.activation_count-1
    end
    name
  end
  
  # True if the context is active
  def active?
    activation_count>0
  end
end
