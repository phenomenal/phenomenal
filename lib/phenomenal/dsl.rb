# Define the DSL methods
module Phenomenal::DSL
  #Override included hook method
  def self.included(klass)
    klass.class_eval do
      #Define Context
      def phen_define_context(name=nil,priority=nil)
        Phenomenal::Context.new(name,priority)     
      end
      # Define context with adaptations
      def phen_context(context,*contexts,&block)
        Phenomenal::Context.create(context,*contexts,&block)
      end
      #TODO check kernel repond to method
      alias_method :context, :phen_context
      
      # Define context with adaptations
      def phen_feature(context,*contexts,&block)
        Phenomenal::Feature.create(context,*contexts,&block)
      end
      alias_method :feature, :phen_feature
      
      
      # Forget Context
      def phen_forget_context(context)
        Phenomenal::Manager.instance.find_context(context).forget
      end
      
      # Add adaptation
      def phen_add_adaptation(context,klass, method_name, &implementation)
        Phenomenal::Manager.instance.find_context(context).add_adaptation(
          klass, method_name, &implementation
        )
      end
      
      # Remove Adaptation
      def phen_remove_adaptation(context,klass,method_name) 
        Phenomenal::Manager.instance.find_context(context).remove_adaptation(
          klass,method_name
        )
      end
      
      # Activate Context
      def phen_activate_context(context)
        Phenomenal::Manager.instance.find_context(context).activate
      end
      alias_method :activate_context, :phen_activate_context
      
      # Deactivate Context
      def phen_deactivate_context(context)
        Phenomenal::Manager.instance.find_context(context).deactivate   
      end
      alias_method :deactivate_context, :phen_deactivate_context
      
      # Context is active?
      def phen_context_active?(context)
        Phenomenal::Manager.instance.find_context(context).active?
      end
      
      # Context informations
      def phen_context_information(context)
        Phenomenal::Manager.instance.find_context(context).information
      end
      
      # Default Context
      def phen_default_context
        Phenomenal::Manager.instance.default_context
      end
      
      # Defined context registered in the manager
      def phen_defined_contexts    
        Phenomenal::Manager.instance.contexts.values
      end
      
      # Proceed
      def phen_proceed(*args,&block)
        Phenomenal::Manager.instance.proceed(caller,self,*args,&block)
      end
      alias_method :proceed, :phen_proceed

      # Change conflict resolution policy (for the proceed call)
      def phen_change_conflict_policy(&block)
        Phenomenal::Manager.instance.change_conflict_policy(&block) 
      end
    end
  end
end

#Load the phenomenal primitives as top level methods
module Kernel
  include Phenomenal::DSL
end
