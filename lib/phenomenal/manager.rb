require 'singleton'

# This class manage the different contexts in the system, their creation
# (de)activation, composition,....
class ContextManager
  include Singleton
  
  attr_accessor :active_adaptations, :deployed_adaptations, :contexts
  
  # Create the context 'context_name'
  # If it doesn't already exist
  def define_context(context_name)
    if has_context?(context_name)
      Phenomenal::Logger.instance.error(
        "There is already a context with name: #{context_name}"
      )
    end
    contexts[context_name] = Context.new(context_name)
    nil
  end

  # Destroy the context 'context_name', if default context => reset it
  def forget_context(context_name)
    if context_active?(context_name)
      Phenomenal::Logger.instance.error(
        "Active context cannot be forgotten"
      )
    else
      if context_name==:default && !contexts.size==1
        Phenomenal::Logger.instance.error(
          "Default context can only be forgotten when alone"
        )
      else
        contexts.delete(context_name)
        init_default() if context_name==:default
      end
    end
  end
  
  # Check wether context 'context_name' is currently active
  def context_active?(context_name)
    find_context(context_name).active?
  end
  
  # Add a new adaptation to context 'context_name'
  def add_adaptation(context_name, klass, method_name, &implementation)
    if klass.instance_methods.include?(method_name)
      method = klass.instance_method(method_name)
    elsif klass.methods.include?(method_name)
      method = klass.method(method_name)
    else
      Phenomenal::Logger.instance.error(
        "Error: Illegal adaptation for context #{context_name},a method with "+
        "name: #{method_name} should exist in class #{klass.name} to be adapted"
      )
    end
    if method.arity != implementation.arity
      Phenomenal::Logger.instance.error(
        "Error: Illegal adaptation for context #{context_name},the adaptation "+ 
        "have to keep the original method arity for method: " +
        "#{klass.name}.#{method_name}: (#{meth.arity} instead of " +
        "#{implementation.arity})" 
      )
    end
    current_context = find_context(context_name)
    default_adaptation = find_context(:default).adaptations.find do|i| 
        i.concern(klass,method_name)
      end
    if context_name!=:default && !default_adaptation
        save_default_adaptation(klass, method_name)
    end
    adaptation = 
      current_context.add_adaptation(klass,method_name,implementation)
    activate_adaptation(adaptation) if current_context.active?
  end
  
  #TODO Activate adaptation

  private
  
  # Save the default adaptation of a method, ie: the initial method
  def save_default_adaptation(klass, method_name)
    default_context = find_context(:default)
    if klass.instance_methods.include?(method_name)
      method = klass.instance_method(method_name)
    else
      method = klass.method(method_name)
    end
    adaptation = default_context.add_adaptation(klass,method_name,method)
    activate_adaptation(adaptation) if default_context.active?
  end
  
  # Return the context 'context_name'
    def find_context(context_name)
      if !has_context?(context_name)
        Phenomenal::Logger.instance.error(
          "There is no context with name: #{context_name}"
        )
      end
      contexts[context_name]
    end
    
  # Check wether context 'context_name' exist in the context manager
  def has_context?(context_name)
    contexts.has_key?(context_name)
  end
  
   # Set the default context
  def init_default
    define_context(:default)
    activate_context(:default)
  end

  # Private constructor because this is a singleton object
  def initialize
    self.contexts = Hash.new
    self.deployed_adaptations = Array.new
    self.active_adaptations = Array.new
    init_default()
  end
end
