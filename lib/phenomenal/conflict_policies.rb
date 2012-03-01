# Context conflict resolution policies
module Phenomenal::ConflictPolicies
  
  # Prefer not default adaptation, error if two not default ones
    def no_resolution_conflict_policy(context1,context2)
      if context1==default_context()
        1
      elsif context2==default_context()
        -1
      else #Fail if two non default adaptations
        Phenomenal::Logger.instance.error(
            "Illegal duplicate adapation between contexts #{context1} and #{context2} "
        )
      end
    end

    # Age based conflict resolution
    def age_conflict_policy(context1, context2)
       context1.age <=> context2.age
    end
end
