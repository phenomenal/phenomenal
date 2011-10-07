# Context exceptions
class ContextError < StandardError; end

# Utilities methods
module ContextUtils
  # True if klass.method_name is an instance method
  def instance_method?(klass,method_name)
    klass.instance_methods.include?(method_name)
  end

  # True if klass.method_name is an class method
  def class_method?(klass,method_name)
    klass.methods.include?(method_name)
  end
end

# Context conflict resolution policies
module ConflictPolicies
  # Prefer not default adaptation, error if two not default ones
    def no_resolution_conflict_policy(adaptation1,adaptation2)
      if adaptation1.context.name==:default
        1
      elsif adaptation2.context.name==:default
        -1
      else #Fail if two non default adaptations
        raise(ContextError,
            "Error: Illegal duplicate adapation of #{adaptation1.to_s}")
      end
    end

    # Age based conflict resolution
    def age_conflict_policy(adaptation1, adaptation2)
       adaptation1.context.activation_age <=> adaptation2.context.activation_age
    end
end

