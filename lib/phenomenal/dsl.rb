# Define the DSL methods
module Phenomenal::DSL
  #Override included hook method
  def self.included(klass)
    klass.class_eval do
      # Define context with adaptations
      def phen_context(context,*contexts,&block)
        Phenomenal::Context.create(false,nil,context,*contexts,&block)
      end
      Phenomenal::DSL.phen_alias(:context,klass)
      
      # Define context with adaptations
      def phen_feature(context,*contexts,&block)
        Phenomenal::Feature.create(false,nil,context,*contexts,&block)
      end
      Phenomenal::DSL.phen_alias(:feature,klass)
      
      # Forget Context
      def phen_forget_context(context)
        Phenomenal::Manager.instance.find_context(context).forget
      end
      
      # Add adaptation
      def phen_add_adaptation(context,klass, method_name, &implementation)
        Phenomenal::Manager.instance.find_context(context).add_adaptation(
          klass, method_name,true, &implementation
        )
      end
      
      def phen_add_class_adaptation(context,klass, method_name, &implementation)
        Phenomenal::Manager.instance.find_context(context).add_adaptation(
          klass, method_name,false, &implementation
        )
      end
      
      # Remove Adaptation
      def phen_remove_adaptation(context,klass,method_name) 
        Phenomenal::Manager.instance.find_context(context).remove_adaptation(
          klass,method_name,true
        )
      end
      
      def phen_remove_class_adaptation(context,klass,method_name) 
        Phenomenal::Manager.instance.find_context(context).remove_adaptation(
          klass,method_name,false
        )
      end
      
      # Activate Context
      def phen_activate_context(context,*contexts)
        contexts=[] if contexts.nil?
        contexts.push(context)
        contexts.each do |c|
          Phenomenal::Manager.instance.find_context(c).activate
        end
      end
      Phenomenal::DSL.phen_alias(:activate_context,klass)
      
      # Deactivate Context
      def phen_deactivate_context(context,*contexts)
        contexts=[] if contexts.nil?
        contexts.push(context)
        contexts.each do |c|
          Phenomenal::Manager.instance.find_context(c).deactivate 
        end 
      end
      Phenomenal::DSL.phen_alias(:deactivate_context,klass)
      
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
      Phenomenal::DSL.phen_alias(:proceed,klass)

      # Change conflict resolution policy (for the proceed call)
      def phen_change_conflict_policy(&block)
        Phenomenal::Manager.instance.change_conflict_policy(&block) 
      end
    end
    # Add relationships specific DSL
    define_relationships(klass)
    # Add Viewers specific DSL
    define_viewers(klass)
  end
  
  private
  def self.phen_alias(method,klass)
    if Kernel.respond_to? method
      Phenomenal::Logger.instance.warn(
        "The Phenomenal DSL keyword #{method} wasn't defined, use"+
        " phen_#{method} instead"
      )
    else
      klass.class_eval do
        alias_method method, "phen_#{method}"
      end
    end
  end
end

#Load the phenomenal primitives as top level methods
module Kernel
  include Phenomenal::DSL
end
