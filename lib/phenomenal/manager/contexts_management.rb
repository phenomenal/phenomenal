module Phenomenal::ContextsManagement
  attr_accessor :contexts, :default_context, :combined_contexts, :shared_contexts
  
  # Register a new context 
  def register_context(context)
    if context_defined?(context)
      Phenomenal::Logger.instance.error(
        "The context #{context} is already registered"
      )
    end
    if context.name && context_defined?(context.name)
      Phenomenal::Logger.instance.error(
        "There is already a context with name: #{context.name}." + 
        " If you want to have named context it has to be a globally unique name"
      )
    end
    # Update the relationships that concern this context
    rmanager.update_relationships_references(context)
    # Store the context at its ID
    contexts[context]=context
  end
  
  # Unregister a context (forget)
  def unregister_context(context)
    if context==default_context && contexts.size>1
      Phenomenal::Logger.instance.error(
        "Default context can only be forgotten when alone"
      )
    else
      contexts.delete(context)
      unregister_combined_contexts(context)
      # Restore default context
      init_default() if context==default_context
    end
  end
  
  
  
  # Activate the context 'context' and deploy the related adaptation
  def activate_context(context)
    begin
      # Relationships managment
      rmanager.activate_relationships(context) if context.just_activated?   
      # Activation of adaptations
      context.adaptations.each{ |i| activate_adaptation(i) }
      # Activate combined contexts
      activate_combined_contexts(context)
    rescue Phenomenal::Error
      context.deactivate # rollback the deployed adaptations
      raise # throw up the exception
    end
  end
  
  # Deactivate the adaptations (undeploy if needed)
  def deactivate_context(context)
    #Relationships managment
    rmanager.deactivate_relationships(context)
    #Adaptations deactivation
    context.adaptations.each do |i| 
      deactivate_adaptation(i) 
    end
    deactivate_combined_contexts(context)
  end
  
  # Return the corresponding context (or combined context) or raise an error 
  # if the context isn't currently registered.
  # The 'context' parameter can be either a reference to a context instance or
  # a Symbol with the name of a named (not anonymous) context.
  def find_context(context, *contexts)
    if contexts.length==0
      find_simple_context(context)
    else #Combined contexts
      contexts.insert(0,context)
      find_combined_context(contexts)
    end
  end
  
  # Check wether context 'context' (or combined context) exist in the context manager
  # Context can be either the context name or the context instance itself
  # Return the context if found, or nil otherwise
  def context_defined?(context, *contexts)
    c=nil
    begin
      c = find_context(context,*contexts)
    rescue Phenomenal::Error
      return nil
    end
    return c
  end
  
  private
  def unregister_combined_contexts(context)
    # Forgot combined contexts
    combined_contexts.delete(context)
    if shared_contexts[context]
      shared_contexts[context].each do |c|
        c.forget
      end
    end
  end
  
  def activate_combined_contexts(context)
    if shared_contexts[context]
      shared_contexts[context].each do |combined_context|
        need_activation=true
        combined_contexts[combined_context].each do |shared_context|
          need_activation=false if !shared_context.active?
      end
      combined_context.activate if need_activation
      end
    end
  end
  
  def deactivate_combined_contexts(context)
    if shared_contexts[context]
      shared_contexts[context].each do |combined_context|
        while combined_context.active? do
         combined_context.deactivate
        end
      end
    end
  end
  
  def find_simple_context(context)
    find=nil
    if !context.kind_of?(Phenomenal::Context)
      a = contexts.find{|k,v| v.name==context}
      if a
        find = a[1]
      end
    else
      find = context if contexts.has_key?(context)
    end
    if find
      find
    else
      Phenomenal::Logger.instance.error(
        "Unknown context #{context}"
      )
    end
  end
  
  def find_combined_context(contexts)
    list=Array.new
    contexts.each do |c|
      # Use the object instance if already available
      # otherwise use the symbol name
      c = find_simple_context(c) if context_defined?(c)
      if shared_contexts[c]==nil
        list.clear
        break
      elsif list.length==0
        # clone otherwise list.clear empty shared_contexts[c]
        list=shared_contexts[c].clone 
      else
          list=shared_contexts[c].find_all{|i| list.include?(i) } 
      end
    end
    if list.length==0
      Phenomenal::Logger.instance.error(
        "Unknown combined context #{contexts}"
      )
    elsif list.length==1
      return list.first
    else
      Phenomenal::Logger.instance.error(
        "Multiple definition of combined context #{contexts}"
      )
    end
  end
end
