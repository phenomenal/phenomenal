module Phenomenal::AdaptationsManagement
  attr_accessor :active_adaptations, :deployed_adaptations
  
  # Register a new adaptation for a registered context
  def register_adaptation(adaptation)
    default_adaptation = default_feature.adaptations.find do|i| 
      i.concern?(adaptation.klass,adaptation.method_name,adaptation.instance_adaptation?)
    end
    if adaptation.context!=default_feature && !default_adaptation
      save_default_adaptation(adaptation.klass, adaptation.method_name,adaptation.instance_adaptation?)
    end
    activate_adaptation(adaptation) if adaptation.context.active?
  end
  
  # Unregister an adaptation for a registered context
  def unregister_adaptation(adaptation)
    deactivate_adaptation(adaptation) if adaptation.context.active?
  end
  
  # Call the old implementation of the method 'caller.caller_method'
  def proceed(calling_stack,instance,*args,&block)
    calling_adaptation = find_adaptation(calling_stack)
    # IMPROVE Problems will appears if proceed called in a file where
    # adaptations are defined but not in one of them=> how to check?
    # IMPROVE Problems will also appears if two adaptations are defined on the 
    # same line using the ';' some check needed at add_adaptation ?
    adaptations_stack = sorted_adaptations_for(calling_adaptation.klass,  
      calling_adaptation.method_name,calling_adaptation.instance_adaptation?)
    calling_adaptation_index = adaptations_stack.find_index(calling_adaptation)
    next_adaptation = adaptations_stack[calling_adaptation_index+1]
    next_adaptation.bind(instance,*args, &block)
  end
  
  private 
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
    # Do nothing when to_deploy==nil to break at default feature deactivation
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
    adaptation = default_feature.add_adaptation(klass,method_name,instance,method)
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
    relevants = active_adaptations.find_all{ |i| i.src_file == call_file }
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
      active_adaptations.find_all{ |i| i.concern?(klass, method_name,instance) }
    relevants.sort!{|a,b| conflict_policy(a.context,b.context)}
  end
end
