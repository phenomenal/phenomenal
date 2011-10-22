# Context conflict resolution policies
module Phenomenal::ConflictPolicies
  # Prefer not default adaptation, error if two not default ones
    def no_resolution_conflict_policy(adaptation1,adaptation2)
      if adaptation1.context==default_context()
        1
      elsif adaptation2.context.name==default_context()
        -1
      else #Fail if two non default adaptations
        Phenomenal::Logger.instance.error(
            "Error: Illegal duplicate adapation of #{adaptation1.to_s}"
        )
      end
    end

    # Age based conflict resolution
    def age_conflict_policy(adaptation1, adaptation2)
       adaptation1.context.age <=> adaptation2.context.age
    end
end
