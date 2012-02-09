class Phenomenal::Viewer::Textual
  require "graphviz"
  attr_reader :manager, :rmanager
  
  def initialize()
    @manager=Phenomenal::Manager.instance
    @rmanager=Phenomenal::RelationshipsManager.instance
  end
  
  def generate()
    str=""
    offset="  "
    self.manager.contexts.each do |key,context|
      if context.is_a?(Phenomenal::Feature)
        type="Feature"
        str=str+"#{type}: #{context.to_s} \n"
        context.relationships.each do |relationship|
          if relationship.is_a?(Phenomenal::Implication)
            relation="=>"
          elsif relationship.is_a?(Phenomenal::Suggestion)
            relation="->"
          elsif relationship.is_a?(Phenomenal::Requirement)
            relation="=<"
          else
            relation="??"
          end
          str=str+"#{offset} #{relationship.source.to_s} #{relation} #{relationship.target.to_s} \n"
       end
     else
       type="Context"
       str=str+"#{type}: #{context.to_s} \n"
     end
   end
     str
  end
end