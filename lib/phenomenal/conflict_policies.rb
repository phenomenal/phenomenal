# Context conflict resolution policies
module Phenomenal::ConflictPolicies
  # Prefer not default adaptation, error if two not default ones
    def no_resolution_conflict_policy(adaptation1,adaptation2)
      if adaptation1.context.name==:default
        1
      elsif adaptation2.context.name==:default
        -1
      else #Fail if two non default adaptations
        Phenomenal::Logger.instance.error(
            "Error: Illegal duplicate adapation of #{adaptation1.to_s}"
        )
      end
    end

    # Age based conflict resolution
    def age_conflict_policy(adaptation1, adaptation2)
       pnml_context_age(adaptation1.context.name) <=> pnml_context_age(adaptation2.context.name)
    end
end
