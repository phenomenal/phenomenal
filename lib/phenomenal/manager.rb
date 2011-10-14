require 'singleton'

# This class manage the different contexts in the system, their creation
# (de)activation, composition,....
class Phenomenal::Manager
  include Singleton
  include Phenomenal::ConflictPolicies
  
  attr_accessor :active_adaptations, :deployed_adaptations, :contexts
  
  # Create the context 'context_name'
  # If it doesn't already exist
  def define_context(context_name)
    if has_context?(context_name)
      Phenomenal::Logger.instance.error(
        "There is already a context with name: #{context_name}"
      )
    end
    contexts[context_name] = Phenomenal::Context.new(context_name)
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
        i.concern?(klass,method_name)
      end
    if context_name!=:default && !default_adaptation
        save_default_adaptation(klass, method_name)
    end
    adaptation = 
      current_context.add_adaptation(klass,method_name,implementation)
    activate_adaptation(adaptation) if current_context.active?
  end

  # Remove an adaptation from context 'context_name'
  def remove_adaptation(context_name,klass, method_name)
    current_context = find_context(context_name)
    adaptation = current_context.remove_adaptation(klass,method_name)
    deactivate_adaptation(adaptation) if current_context.active?
  end
  
  # Activate the context 'context_name' and deploy the related adaptation
  def activate_context(context_name)
    current_context = find_context(context_name)
    current_context.activate
    begin
      current_context.adaptations.each{ |i| activate_adaptation(i) }
    rescue Phenomenal::Error
      deactivate_context(context_name) # rollback the deployed adaptations
      raise # throw up the exception
    end
    nil
  end
  
  #TODO contexts task
  # Deactivate 'context_name'
  def deactivate_context(context_name)
    current_context = find_context(context_name)
    was_active = current_context.active?
    current_context.deactivate
    if was_active && !current_context.active?
      current_context.adaptations.each{ |i| deactivate_adaptation(i) }
    end
    nil
  end
  
  # Call the old implementation of the method 'caller.caller_method'
  def proceed(calling_stack,instance,*args,&block)
    calling_adaptation = find_adapatation(calling_stack)
    #TODO Problems will appears if proceed called in a file where
    # adaptations are defined but not in one of them=> how to check?
    #TODO Problems will also appears if two adaptations are defined on the same
    # line using the ';' some check needed at add_adaptation ?
    adaptations_stack = sorted_adaptations_for(calling_adaptation.klass,  
      calling_adaptation.method_name)
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

  # Return the activation age of the context:
  #  The age counter minus the age counter when the context was activated
  #  for the last time
  #TODO Good place for this one ?
  def context_age(context)
    current_context = find_context(context)
    if current_context.activation_age == 0
      Phenomenal::Context.total_activations
    else
      Phenomenal::Context.total_activations-current_context.activation_age
    end
  end
  
  
  # Return context informations:
  #   - name
  #   - List of the adaptations names
  #   - active state
  #   - activation age
  def context_informations(context_name)
    context = find_context(context_name)
    adaptations_array = Array.new
    context.adaptations.each{ |i| adaptations_array.push(i.to_s) }
    {
      :name=>context.name,
      :adaptations=>adaptations_array,
      :active=>context.active?,
      :activation_age=>context_age(context_name)
    }
  end
  
  def deactivate_all_contexts
    contexts.each do |k,v|
      if k!=:default
        while v.active?
          deactivate_context(k)
        end
      end
    end
    nil
  end
  
  # ==== Private methods ==== #
  private
  # Activate the adaptation and redeploy the adaptations to take the new one
  # one in account
  def activate_adaptation(adaptation)
    if !active_adaptations.include?(adaptation)
      active_adaptations.push(adaptation)
    end
    redeploy_adaptation(adaptation.klass,adaptation.method_name)
  end
  
  # Deactivate the adaptation and redeploy the adaptations if necessary
  def deactivate_adaptation(adaptation)
    active_adaptations.delete(adaptation)
    if deployed_adaptations.include?(adaptation)
      deployed_adaptations.delete(adaptation)
      redeploy_adaptation(adaptation.klass,adaptation.method_name)
    end
  end
  
  # Redeploy the adaptations concerning klass.method_name according to the
  # conflict policy
  def redeploy_adaptation(klass, method_name)
    to_deploy = resolve_conflict(klass,method_name)
    # Do nothing when to_deploy==nil to break at default context deactivation
    if !deployed_adaptations.include?(to_deploy) && to_deploy!=nil
      deploy_adaptation(to_deploy)
    end
  end
  
  # Deploy the adaptation
  def deploy_adaptation(adaptation)
    to_undeploy = deployed_adaptations.find do |i|
                          i.concern?(adaptation.klass,adaptation.method_name)
                        end
    if to_undeploy!=adaptation # if new adaptation
      deployed_adaptations.delete(to_undeploy)
      deployed_adaptations.push(adaptation)
      adaptation.deploy
    end
  end
  
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
  
  # Return the adaptation that math the calling_stack, on the basis of the
  # file and the line number --> proceed is always called under an
  # adaptation definition
  def find_adapatation(calling_stack)
    source = calling_stack[0]
    source_info = source.scan(/(.+\.rb):(\d+)/)[0]
    call_file = source_info[0]
    call_line = source_info[1].to_i
    i = 0
    match = nil
    relevants = active_adaptations.select{ |i| i.src_file == call_file }
    # Sort by src_line DESC
    relevants.sort!{ |a,b| b.src_line <=> a.src_line }
    relevants.each do |adaptation|
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
  
  # Return the context 'context_name'
  def find_context(context_name)
    if !has_context?(context_name)
      Phenomenal::Logger.instance.error(
        "There is no context with name: #{context_name}"
      )
    end
    contexts[context_name]
  end
  
   # Return the best adaptation according to the resolution policy
  def resolve_conflict(klass,method_name)
    sorted_adaptations_for(klass,method_name).first
  end
  
  # Return the adaptations for a particular method sorted with the
  # conflict policy
  def sorted_adaptations_for(klass,method_name)
    relevant_adaptations =
      active_adaptations.find_all { |i| i.concern?(klass, method_name) }
    relevant_adaptations.sort!{|a,b| conflict_policy(a,b)}
  end
  
  # Resolution policy
  def conflict_policy(adaptation1, adaptation2)
    no_resolution_conflict_policy(adaptation1, adaptation2)
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
    @contexts = Hash.new
    @deployed_adaptations = Array.new
    @active_adaptations = Array.new
    init_default()
  end
end
