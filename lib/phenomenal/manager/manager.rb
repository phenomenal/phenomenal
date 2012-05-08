require 'singleton'
# This class manage the different contexts in the system and their interactions
class Phenomenal::Manager
  include Singleton
  include Phenomenal::ConflictPolicies
  include Phenomenal::AdaptationsManagement
  include  Phenomenal::ContextsManagement
  
  attr_accessor :rmanager
  
  
  # Resolution policy
  def conflict_policy(context1, context2)
    age_conflict_policy(context1, context2)
  end
  
  # Change the conflict resolution policy.
  # These can be ones from the ConflictPolicies module or other ones
  # Other one should return -1 or +1 following the resolution order
  def change_conflict_policy (&block)
    self.class.class_eval{define_method(:conflict_policy,&block)}
  end
  
  
  # PRIVATE METHODS
  private
   # Set the default context
  def init_default
    self.default_context= Phenomenal::Feature.new(nil,self)
    self.default_context.activate
  end

  # Private constructor because this is a singleton object
  def initialize
    @contexts = Hash.new
    @deployed_adaptations = Array.new
    @active_adaptations = Array.new
    @combined_contexts = Hash.new
    @shared_contexts = Hash.new
    @rmanager = Phenomenal::RelationshipsManager.instance
    init_default()
  end
end
