module Phenomenal::DSL
  def self.define_relationships(klass)
    klass.class_eval do
      # Requirements
      def requirements_for(source,targets)
        Phenomenal::Manager.instance.default_context.requirements_for(source,targets)
      end
       # Implications
      def implications_for(source,targets)
        Phenomenal::Manager.instance.default_context.implications_for(source,targets)
      end
       # Suggestions
      def suggestions_for(source,targets)
        Phenomenal::Manager.instance.default_context.suggestions_for(source,targets)
      end
    end
  end
end
