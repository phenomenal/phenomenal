# Define the DSL methods for relationships
module Phenomenal::DSL
  def self.define_relationships(klass)
    klass.class_eval do
      # Requirements
      def phen_requirements_for(source,targets)
        Phenomenal::Manager.instance.default_context.requirements_for(source,targets)
      end
      Phenomenal::DSL.phen_alias(:requirements_for,klass)
      
       # Implications
      def phen_implications_for(source,targets)
        Phenomenal::Manager.instance.default_context.implications_for(source,targets)
      end
      Phenomenal::DSL.phen_alias(:implications_for,klass)
      
       # Suggestions
      def phen_suggestions_for(source,targets)
        Phenomenal::Manager.instance.default_context.suggestions_for(source,targets)
      end
      Phenomenal::DSL.phen_alias(:suggestions_for,klass)
      
    end
  end
end
