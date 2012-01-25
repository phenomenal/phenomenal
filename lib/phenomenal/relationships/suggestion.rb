class Phenomenal::Suggestion < Phenomenal::Relationship
  def activate_context(context)
    if source==context
      target.activate
    end
  end
  
  def deactivate_context(context)
    if source==context
      target.deactivate
    end
  end
end
