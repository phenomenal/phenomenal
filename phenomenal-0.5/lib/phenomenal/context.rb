# Represent a first class context
class Context

    @@total_activations = 0
    attr_accessor :activation_count, :name, :adaptations, :creation_time,
                  :activation_time, :age_counter

  def initialize(name)
    self.activation_count=0
    self.name=name
    self.adaptations=Array.new
    self.creation_time=Time.now.to_f
    self.activation_time=0
    self.age_counter=0
  end

  # Add a new method adaptation to the context
  # Return the adaptation just created
  def add_adaptation(klass, method_name, implementation)
    if adaptations.find{ |i| i.concern(klass,method_name) }
      raise(ContextError, %(Error: Illegal duplicated adaptation in context:
                            #{self.name} for #{klass.name}:#{method_name}))
    else
      adaptation = ContextAdaptation.new(self,klass, method_name,implementation)
      self.adaptations.push(adaptation)
      adaptation
    end
  end

  # Remove a method adaptation from the context
  def remove_adaptation(klass,method_name)
    adaptation_index =
      adaptations.find_index{ |i| i.concern(klass, method_name) }
    if !adaptation_index
      raise(ContextError, %(Error: Illegal deleting of an inexistent
                            adaptation in context: #{self.name} for
                            #{klass.name}.#{method_name}))
    end
    adaptations.delete_at(adaptation_index)
  end

  # Return the activation age of the context:
  #  The age counter minus the age counter when the context was activated
  #  for the last time
  def activation_age
    if self.age_counter == 0
      @@total_activations
    else
      @@total_activations-age_counter
    end
  end

  # Activate the context
  def activate
    @@total_activations = @@total_activations+1
    self.age_counter = @@total_activations
    self.activation_time = Time.now.to_f
    self.activation_count= self.activation_count+1
    self.name
  end

  # Deactivate the context
  def deactivate
    if self.activation_count>0
      self.activation_count= self.activation_count-1
    end
    if self.activation_count==0
      self.activation_time = 0
    end
    self.name
  end

  # True if the context is active
  def active?
    self.activation_count>0
  end
end

