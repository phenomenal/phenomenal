module Phenomenal::DSL
  def dsl_define_context(name=nil,priority=nil)
    Phenomenal::Context.new(name,priority)     
  end
  
  def dsl_forget_context(context)
    find_context(context).forget
  end
  
  def dsl_add_adaptation(context,klass, method_name, &implementation)
    find_context(context).add_adaptation(klass, method_name, &implementation)
  end
  
  def dsl_remove_adaptation(context,klass,method_name) 
    find_context(context).remove_adaptation(klass,method_name)
  end
  
  def dsl_activate_context(context)
    find_context(context).activate
  end
  
  def dsl_deactivate_context(context)
    find_context(context).deactivate   
  end

  def dsl_context_active?(context)
    find_context(context).active?
  end
  
  def dsl_context_informations(context)
    find_context(context).informations
  end

  def dsl_change_conflict_policy(&block)
    change_conflict_policy(&block) 
  end

  def dsl_default_context
    default_context
  end
  
  def dsl_defined_contexts    
    contexts.values
  end
  #TODO proceed is defined mannualy in DSLDefinition in order to use callee
end
