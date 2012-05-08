require 'singleton'
# This class manage the different contexts in the system and their interactions
class Phenomenal::Manager
  include Singleton
  include Phenomenal::ConflictPolicies
  
  attr_accessor :active_adaptations, :deployed_adaptations, :contexts, 
  :default_context, :combined_contexts, :shared_contexts, :rmanager
  
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
  
  # Register a new adaptation for a registered context
  def register_adaptation(adaptation)
    default_adaptation = default_context.adaptations.find do|i| 
      i.concern?(adaptation.klass,adaptation.method_name,adaptation.instance_adaptation?)
    end
    if adaptation.context!=default_context && !default_adaptation
      save_default_adaptation(adaptation.klass, adaptation.method_name,adaptation.instance_adaptation?)
    end
    activate_adaptation(adaptation) if adaptation.context.active?
  end
  
  # Unregister an adaptation for a registered context
  def unregister_adaptation(adaptation)
    deactivate_adaptation(adaptation) if adaptation.context.active?
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
  
  # Call the old implementation of the method 'caller.caller_method'
  def proceed(calling_stack,instance,*args,&block)
    calling_adaptation = find_adaptation(calling_stack)
    # IMPROVE Problems will appears if proceed called in a file where
    # adaptations are defined but not in one of them=> how to check?
    # IMPROVE Problems will also appears if two adaptations are defined on the same
    # line using the ';' some check needed at add_adaptation ?
    adaptations_stack = sorted_adaptations_for(calling_adaptation.klass,  
      calling_adaptation.method_name,calling_adaptation.instance_adaptation?)
    calling_adaptation_index = adaptations_stack.find_index(calling_adaptation)
    next_adaptation = adaptations_stack[calling_adaptation_index+1]
    next_adaptation.bind(instance,*args, &block)
  end
  
  # Change the conflict resolution policy.
  # These can be ones from the ConflictPolicies module or other ones
  # Other one should return -1 or +1 following the resolution order
  def change_conflict_policy (&block)
    self.class.class_eval{define_method(:conflict_policy,&block)}
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
  
  
  # Resolution policy
  def conflict_policy(context1, context2)
    age_conflict_policy(context1, context2)
  end

  # PRIVATE METHODS
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
  
  # Activate the adaptation and redeploy the adaptations to take the new one
  # one in account
  def activate_adaptation(adaptation)
    if !active_adaptations.include?(adaptation)
      active_adaptations.push(adaptation)
    end
    redeploy_adaptation(adaptation.klass,adaptation.method_name,adaptation.instance_adaptation?)
  end
  
  # Deactivate the adaptation and redeploy the adaptations if necessary
  def deactivate_adaptation(adaptation)
    active_adaptations.delete(adaptation)
    if deployed_adaptations.include?(adaptation)
      deployed_adaptations.delete(adaptation)
      redeploy_adaptation(adaptation.klass,adaptation.method_name,adaptation.instance_adaptation?)
    end
  end
  
  # Redeploy the adaptations concerning klass.method_name according to the
  # conflict policy
  def redeploy_adaptation(klass, method_name,instance)
    to_deploy = resolve_conflict(klass,method_name,instance)
    # Do nothing when to_deploy==nil to break at default context deactivation
    if !deployed_adaptations.include?(to_deploy) && to_deploy!=nil
      deploy_adaptation(to_deploy)
    end
  end
  
  # Deploy the adaptation
  def deploy_adaptation(adaptation)
    to_undeploy = deployed_adaptations.find do |i|
                          i.concern?(adaptation.klass,adaptation.method_name,adaptation.instance_adaptation?)
                        end
    if to_undeploy!=adaptation # if new adaptation
      deployed_adaptations.delete(to_undeploy)
      deployed_adaptations.push(adaptation)
      adaptation.deploy
    end
  end
  
  # Save the default adaptation of a method, ie: the initial method
  def save_default_adaptation(klass, method_name,instance)
    if instance
      method = klass.instance_method(method_name)
    else
      method = klass.method(method_name)
    end
    adaptation = default_context.add_adaptation(klass,method_name,instance,method)
  end
  
  # Return the adaptation that math the calling_stack, on the basis of the
  # file and the line number --> proceed is always called under an
  # adaptation definition
  def find_adaptation(calling_stack)
    call_file,call_line = parse_stack(calling_stack)
    match = nil
    relevant_adaptations(call_file).each do |adaptation|
      if adaptation.src_line <= call_line # Find first matching line
        match = adaptation
        break
      end
    end

    if  match==nil
      Phenomenal::Logger.instance.error(
        "Inexistant adaptation for proceed call at #{call_file}:#{call_line}"
      )
    end
    match
  end
  
  # Parse calling stack to find the calling line and file
  def parse_stack(calling_stack)
    source = calling_stack[0]
    source_info = source.scan(/(.+\.rb):(\d+)/)[0]
    call_file = source_info[0]
    call_line = source_info[1].to_i
    [call_file,call_line]
  end
  
  # Gets the relevants adaptations for a file in DESC order of line number
  def relevant_adaptations(call_file)
    relevants = active_adaptations.select{ |i| i.src_file == call_file }
    # Sort by src_line DESC order
    relevants.sort!{ |a,b| b.src_line <=> a.src_line }
  end
  
   # Return the best adaptation according to the resolution policy
  def resolve_conflict(klass,method_name,instance)
    sorted_adaptations_for(klass,method_name,instance).first
  end
  
  # Return the adaptations for a particular method sorted with the
  # conflict policy
  def sorted_adaptations_for(klass,method_name,instance)
    relevants =
      active_adaptations.find_all { |i| i.concern?(klass, method_name,instance) }
    relevants.sort!{|a,b| conflict_policy(a.context,b.context)}
  end
  
   # Set the default context
  def init_default
    self.default_context= Phenomenal::Feature.new(nil,self)
    self.default_context.activate
  end

  # Private constructor because this is a singleton object
  def initialize
    @contexts = Hash.new
    @deployed_adaptations = Array.new
    @active_adaptations = Array.new
    @combined_contexts = Hash.new
    @shared_contexts = Hash.new
    @rmanager = Phenomenal::RelationshipsManager.instance
    init_default()
  end
end
