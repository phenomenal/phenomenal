# Context conflict resolution policies
module Phenomenal::ConflictPolicies
  # Prefer not default adaptation, error if two not default ones
    def no_resolution_conflict_policy(context1,context2)
      if context1==default_feature()
        1
      elsif context2==default_feature()
        -1
      else #Fail if two non default adaptations
        raise(Phenomenal::Error,
          "Illegal duplicate adapation between contexts #{context1}"+ 
          "and #{context2} "
        )
      end
    end

    # Age based conflict resolution
    def age_conflict_policy(context1, context2)
       context1.age <=> context2.age
    end
    
    # Priority based conflict resolution
    def priority_conflict_policy(context1, context2)
      if context1.priority && !context2.priority
        -1
      elsif context2.priority && !context1.priority
        1
      elsif context1.priority!=context2.priority
        context1.priority <=> context2.priority
      else
        context1.age <=> context2.age
      end
    end
    
    # Resolution policy
    def conflict_policy(context1, context2)
      age_conflict_policy(context1, context2)
    end

    # Change the conflict resolution policy.
    # These can be ones from the ConflictPolicies module or other ones
    # Other one should return -1 or +1 following the resolution order
    def change_conflict_policy (&block)
      self.class.class_eval{define_method(:conflict_policy,&block)}
      nil
    end
end
