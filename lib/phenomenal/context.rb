# Represent a first class context
class Phenomenal::Context
  
  @@total_activations = 0
  def self.create(context,*contexts,nested,&block)
    manager = Phenomenal::Manager.instance
    contexts.insert(0,context)
    if contexts.length==1
      if !manager.context_defined?(context)
        context = self.new(context) 
      else
        context = manager.find_context(context)
        if !context.instance_of?(self)
          Phenomenal::Logger.instance.error(
            "Only #{self.name} can be used in the declaration"
          )
        end
      end
    else #Combined contexts
      if !manager.context_defined?(*contexts) # New combined context
        context = self.new
        instances = Array.new
        first = contexts.first
        contexts.each do |c|
          # Use the object instance if already available
          # otherwise create it
          if manager.context_defined?(c)
            c = manager.find_context(c) 
            if !nested && c!=first && !c.instance_of?(self)
              Phenomenal::Logger.instance.error(
                "Only #{self.name} can be used in the declaration"
              )
            end
          else
            c = self.new(c) 
          end
          instances.push(c)
          manager.shared_contexts[c]= Array.new if !manager.shared_contexts[c]
          manager.shared_contexts[c].push(context)
        end
        manager.combined_contexts[context] = instances
      else
        context = manager.find_context(*contexts)
      end
    end
    context.add_adaptations(&block)
    context
  end
  
  attr_accessor :activation_age, :activation_frequency, :priority, :adaptations, 
    :activation_count,:is_required,:is_implied,:activated_suggested,:parent
  attr_reader :manager,:name
  
  def initialize(name=nil, priority=nil,manager=nil)
    @manager = manager || Phenomenal::Manager.instance
    @name = name
    @priority = priority
    @activation_age = 0
    @activation_count = 0
    @adaptations = Array.new
    @manager.register_context(self)
    
    #relationships
    @parent = nil
    @is_implied = {}
    @is_required = {}
    @activated_suggested={}
  end
  
  # Unregister the context from the context manager,
  # This context shoudn't be used after.
  # The context has to be inactive before being forgetted
  # TODO Find a way to avoid the use of forgeted context (use forgeted flag?)
  #TODO Handle combined contexts
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
  
  # Catch nested context and feature calls and transform them in nested contexts
  # creation
  def context(context,*contexts,&block)
    c = Phenomenal::Context.create(self,context,*contexts,true,&block)
    c.parent = self
    c
  end
  alias_method :phen_context,:context

  # Add multiple adaptations at definition time
  def add_adaptations(&block)
    instance_eval(&block) if block
  end
  
  # Set the current adapted class for the next adapt calls
  def adaptations_for(klass)
    @current_adapted_class = klass
  end
  
  # Adapt a method for @current_adapted_class
  def adapt(method,&block)
    add_adaptation(@current_adapted_class,method,&block)
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
    @@total_activations +=1
    self.activation_age =@@total_activations
    self.activation_count = self.activation_count+1
    manager.activate_context(self)
    self
  end  
  
  # Deactivate the context
  def deactivate(caller_context=nil)
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
  
  # Return the activation age of the context:
  #  The age counter minus the age counter when the context was activated
  #  for the last time
  def age
    @@total_activations-activation_age
  end
  
  # Return context informations:
  #   - Name
  #   - List of the adaptations
  #   - Active state
  #   - Activation age
  #   - Activation count
  def information
    {
      :name=>name,
      :adaptations=>adaptations,
      :active=>active?,
      :activation_age=>age,
      :activation_count=>activation_count,
      :type=>self.class.name
    }
  end
  
  def parent_feature
    c = parent
    while c!=nil && !c.is_a?(Phenomenal::Feature) do
      c=c.parent
    end
    if c==nil
      @manager.default_context
    else
      c
    end
  end
  
  # String representation of the context
  def to_s
    if name
      name.to_s
    elsif self==manager.default_context
      "'Default context'"
    else
      "'Anonymous context'"
    end
  end
end
