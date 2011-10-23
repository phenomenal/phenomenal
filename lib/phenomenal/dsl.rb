# Define the DSL methods
module Phenomenal::DSL
  #Override included hook method
  def self.included(klass)
    klass.class_eval do
      #Define Context
      def pnml_define_context(name=nil,priority=nil)
        Phenomenal::Context.new(name,priority)     
      end
      
      # Forget Context
      def pnml_forget_context(context)
        Phenomenal::Manager.instance.find_context(context).forget
      end
      
      # Add adaptation
      def pnml_add_adaptation(context,klass, method_name, &implementation)
        Phenomenal::Manager.instance.find_context(context).add_adaptation(
          klass, method_name, &implementation
        )
      end
      
      # Remove Adaptation
      def pnml_remove_adaptation(context,klass,method_name) 
        Phenomenal::Manager.instance.find_context(context).remove_adaptation(
          klass,method_name
        )
      end
      
      # Activate Context
      def pnml_activate_context(context)
        Phenomenal::Manager.instance.find_context(context).activate
      end
      
      # Deactivate Context
      def pnml_deactivate_context(context)
        Phenomenal::Manager.instance.find_context(context).deactivate   
      end

      # Context is active?
      def pnml_context_active?(context)
        Phenomenal::Manager.instance.find_context(context).active?
      end
      
      # Context informations
      def pnml_context_informations(context)
        Phenomenal::Manager.instance.find_context(context).informations
      end
      
      # Default Context
      def pnml_default_context
        Phenomenal::Manager.instance.default_context
      end
      
      # Defined context registered in the manager
      def pnml_defined_contexts    
        Phenomenal::Manager.instance.contexts.values
      end
      
      # Proceed
      def pnml_proceed(*args,&block)
        Phenomenal::Manager.instance.proceed(caller,self,*args,&block)
      end

      # Change conflict resolution policy (for the proceed call)
      def pnml_change_conflict_policy(&block)
        Phenomenal::Manager.instance.change_conflict_policy(&block) 
      end
    end
  end
end


#Load the phenomenal primitives as top level methods
module Kernel
  include Phenomenal::DSL
end
