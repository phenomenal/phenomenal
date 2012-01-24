module Phenomenal::ContextRelationships
  def requires(context,*contexts)
    contexts = contexts.push(context)
    contexts.each do |target|
      puts "Me #{self}"
      self.parent_feature.requirements_for(self,{:on=>target})
    end
  end
end
