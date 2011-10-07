require 'singleton'

# This class manage the different contexts in the system, their creation
# (de)activation, composition,....
class ContextManager
  include Singleton
  include ContextUtils
  include ConflictPolicies

  attr_accessor :active_adaptations, :deployed_adaptations, :contexts

    # Create the context 'context_name'
    # If it doesn't already exist
    def kw_context_def(context_name)
      if has_context?(context_name)
        raise(ContextError,
              "There is already a context with name: #{context_name}")
      end
      @contexts[context_name] = Context.new(context_name)
      nil
    end

    # Destroy the context 'context_name', if default context => reset it
    def kw_context_forget(context_name)
      if kw_context_active?(context_name)
        raise(ContextError, "Active context cannot be forgotten")
      else
        if context_name==:default && !contexts.size==1
          raise(ContextError,"Default context can only be forgotten when alone")
        else
          remove_context(context_name)
          init_default if context_name==:default
        end
      end
    end

    # Add a new adaptation to context 'context_name'
    def kw_context_add_adaptation(context_name,
                            klass, method_name, umeth=nil,&implementation)
      # Using an UnboundMethod work only if the method was unbounded from a
      # parent or from the adapted class itself -> umeth.bind doesn't work
      # otherwise
      # --> Seems logical it doesn't work because otherwise methods that access
      # instance variables would crash or have weird behavior
      if  umeth.class==UnboundMethod &&
          klass.class.kind_of?(umeth.owner)
        implementation = umeth
      end

      check_adaptation(context_name,klass,method_name,implementation)
      current_context = get_context(context_name)
      if  context_name!=:default &&
          !get_context(:default).adaptations.find do |i|
                      i.concern(klass,method_name)
                    end
          save_default_adaptation(klass, method_name)
      end

      adaptation =
        current_context.add_adaptation(klass,method_name,implementation)
      activate_adaptation(adaptation) if current_context.active?
    end

    # Remove an adaptation from context 'context_name'
    def kw_context_remove_adaptation(context_name,klass, method_name)
      current_context = get_context(context_name)
      adaptation = current_context.remove_adaptation(klass,method_name)
      deactivate_adaptation(adaptation) if current_context.active?
    end

    # Activate the context 'context_name' and deploy the related adaptation
    def kw_context_activate(context_name)
      current_context = get_context(context_name)
      current_context.activate
      begin
        current_context.adaptations.each{ |i| activate_adaptation(i) }
      rescue ContextError
        kw_context_deactivate(context_name) # rollback the deployed adaptations
        raise # throw up the exception
      end
      nil
    end

    # Deactivate 'context_name'
    def kw_context_deactivate(context_name)
      current_context = get_context(context_name)
      was_active = current_context.active?
      current_context.deactivate
      if was_active && !current_context.active?
        current_context.adaptations.each{ |i| deactivate_adaptation(i) }
      end
      nil
    end

    # Call the old implementation of the method 'caller.caller_method'
    def kw_context_proceed(calling_stack,inst,*args,&block)
      begin
        calling_ad = find_adapatation(calling_stack)
      rescue NameError
        raise(ContextError,%( Error, ctxt_proceed can only be called in an
                              adaptation declaration))
      end

      adaptations_stack =
        sorted_adaptations_for(calling_ad.klass,calling_ad.method_name)
      calling_ad_index = adaptations_stack.find_index(calling_ad)

      next_adaptation = adaptations_stack[calling_ad_index+1]

      ret=nil
      if next_adaptation.instance_adaptation?
        ret = next_adaptation.implementation.bind(inst).call(*args,&block)
      else
        if next_adaptation.implementation.class==Proc
          ret = next_adaptation.implementation.bind_class(
                                      next_adaptation.klass).call(*args,&block)
        else
          ret = next_adaptation.implementation.call(*args,&block)
        end
      end
      ret
    end

    # Return the name off all defined contexts
    def kw_context_list
      contexts.keys
    end

    # Return all currently active contexts
    def kw_context_list_active
      contexts.select{ |k, v| v.active? }.keys
    end

    # Check wether context 'context_name' is currently active
    def kw_context_active?(context_name)
      get_context(context_name).active?
    end

    # Return context informations:
    #   - name
    #   - Time of last activation
    #   - Time of creation
    #   - Activation age
    #   - List of the adaptations names
    #   - active state
    def kw_context_informations(context_name)
      context = get_context(context_name)
      adaptations_array = Array.new
      context.adaptations.each{ |i| adaptations_array.push(i.to_s) }
      {
        :name=>context.name,
        :activation_time=>context.activation_time,
        :creation_time=>context.creation_time,
        :activation_age=>context.activation_age,
        :adaptations=>adaptations_array,
        :active=>context.active?
      }
    end

    # Change the conflict resolution policy.
    # These can be ones from the ConflictPolicies module or other ones
    # Other one should return -1 or +1 following the resolution order
    def kw_context_change_policy (&block)
      self.class.class_eval{define_method(:conflict_policy,&block)}
    end

  # == Private methods == #
  private
    # Return the adaptations for a particular method sorted with the
    # conflict policy
    def sorted_adaptations_for(klass,method_name)
      relevant_adaptations =
        active_adaptations.find_all { |i| i.concern(klass, method_name) }
      relevant_adaptations.sort!{|a,b| conflict_policy(a,b)}
    end

    # Return the best adaptation according to the resolution policy
    def conflict_resolution(klass,method_name)
      sorted_adaptations_for(klass,method_name).first
    end

    # Resolution policy
    def conflict_policy(adaptation1, adaptation2)
      no_resolution_conflict_policy(adaptation1, adaptation2)
    end

    # Save the default adaptation of a method, ie: the initial method
    def save_default_adaptation(klass, method_name)
      default = get_context(:default)
      if instance_method?(klass,method_name)
        meth = klass.instance_method(method_name)
      else
        meth = klass.method(method_name)
      end
      adaptation = default.add_adaptation(klass,method_name,meth)
      activate_adaptation(adaptation) if default.active?
    end

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

    # Redeploy the adaptation concerning klass.method_name according to the
    # conflict policy
    def redeploy_adaptation(klass, method_name)
      to_deploy = conflict_resolution(klass,method_name)
      # Do nothing when to_deploy==nil to break at default context deactivation
      if !deployed_adaptations.include?(to_deploy) && to_deploy!=nil
        deploy_adaptation(to_deploy)
      end
    end

    # Deploy the adaptation
    def deploy_adaptation(adaptation)
      depl = deployed_adaptations.find do |i|
                            i.concern(adaptation.klass,adaptation.method_name)
                          end
      deployed_adaptations.delete(depl)
      deployed_adaptations.push(adaptation)
      adaptation.deploy
    end

    # Check wether context 'context_name' exist in the context manager
    def has_context?(context_name)
      @contexts.has_key?(context_name)
    end

    # Remove the context 'context_name from the context manager'
    def remove_context(context_name)
      @contexts.delete(context_name)
    end

    # Check wether the adaptation to be added is valid
    def check_adaptation(context_name,klass,method_name,implementation)

      if  instance_method?(klass,method_name)
        meth = klass.instance_method(method_name)
      elsif class_method?(klass,method_name)
        meth = klass.method(method_name)
      else
        raise(ContextError, %(Error: Illegal adaptation for context
                      #{context_name},a method with name:
                      #{method_name} should exist in class
                      #{klass.name} to be adapted))
      end
      if meth.arity != implementation.arity
          raise(ContextError, %(Error: Illegal adaptation for context
                #{context_name},the adaptation have to keep the original
                method arity for method: #{klass.name}.#{method_name}:
               (#{meth.arity} instead of #{implementation.arity})) )
        end
    end

    # Return the context 'context_name'
    def get_context(context_name)
      if !has_context?(context_name)
        raise(ContextError, "There is no context with name: #{context_name}")
      end
      @contexts[context_name]
    end


    # Return the adaptation that math the calling_stack, on the basis of the
    # file and the line number --> A ctxt_proceed is always called under an
    # adaptation definition
    def find_adapatation(calling_stack)
      source = calling_stack[0]
      call_file = source.scan(/(.+\.rb):(\d+)/)[0][0]
      call_line = source.scan(/(.+\.rb):(\d+)/)[0][1].to_i
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
        raise(ContextError, %(Inexistant adaptation for ctxt_proceed call
                              at #{file}:#{line}))
      end
      match
    end

    # Set the default context
    def init_default
      kw_context_def(:default)
      kw_context_activate(:default)
    end

    # Private constructor because this is a singleton object
    def initialize
      @contexts={}
      @deployed_adaptations=Array.new
      @active_adaptations=Array.new
      init_default
    end
end

