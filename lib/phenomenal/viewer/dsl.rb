module Phenomenal::DSL
  def self.define_viewers(klass)
    klass.class_eval do
      # Graphical
      def phen_graphical_view(file="view.png")
        Phenomenal::Viewer::Graphical.new(file).generate
      end
      
      #Textual
      def phen_textual_view
        Phenomenal::Viewer::Textual.new.generate
      end
    end
  end
end
