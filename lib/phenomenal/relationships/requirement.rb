class Phenomenal::Requirement < Phenomenal::Relationship
  def activate_feature
    check_requirement
  end
  
  def activate_context(context)
    if(source==context)
      check_requirement
    end
  end
  
  def deactivate_context(context)
    if(target==context)
      source.deactivate
    end
  end
  
  private
  def check_requirement
    if source.active? && !target.active?
      Phenomenal::Logger.instance.error(
        "Requirement of #{target} for #{source} is not satisfied"
      )
    end
  end
end
