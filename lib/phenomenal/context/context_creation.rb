module Phenomenal::ContextCreation
  def create(nested,closest_feature,context,*contexts,&block)
    manager = Phenomenal::Manager.instance
    contexts.insert(0,context)
    if contexts.length==1
      context = find_or_create_simple_context(manager,context)
    else #Combined contexts
      context = find_or_create_combined_context(manager,contexts,nested,closest_feature)
    end
    context.add_adaptations(&block)
    context
  end
  
  private
  def find_or_create_simple_context(manager,context)
    if !manager.context_defined?(context)
      self.new(context) 
    else
      context = manager.find_context(context)
      if !context.instance_of?(self)
        raise(Phenomenal::Error,
          "Only #{self.name} can be used with this keyword."
        )
      end
      context
    end
  end
  
  def find_or_create_combined_context(manager,contexts,nested,closest_feature)
    if !manager.context_defined?(*contexts) # New combined context
      context = create_combined_context(manager,contexts,nested,closest_feature)
    else
      context = manager.find_context(*contexts)
      if !context.instance_of?(self)
        raise(Phenomenal::Error,
          "Only #{self.name} can be used with this keyword."
        )
      end
    end
    context
  end
  
  def create_combined_context(manager,contexts,nested,closest_feature)
    context = self.new
    context.parent=closest_feature # Set parent
    instances = Array.new
    first = contexts.first
    contexts.each do |c|
      # Use the object instance if already available
      # otherwise create it
      if manager.context_defined?(c)
        c = manager.find_context(c) 
        if !nested && c!=first && !c.instance_of?(self)
          raise(Phenomenal::Error,
            "Only #{self.name} can be used with this keyword."
          )
        end
      else
        c = self.new(c) 
      end
      # Inherit from parent priority
      context.priority=[c.priority,context.priority].compact.min
      
      instances.push(c)
      manager.shared_contexts[c]= Array.new if !manager.shared_contexts[c]
      manager.shared_contexts[c].push(context)
    end
    manager.combined_contexts[context] = instances
    context
  end
end
