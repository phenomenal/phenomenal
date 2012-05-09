# Load the gem files in the system
module Phenomenal 
  module Viewer end
end
#Relationships
require_relative "./phenomenal/relationships/context_relationships.rb"
require_relative "./phenomenal/relationships/feature_relationships.rb"
require_relative "./phenomenal/relationships/relationships_store.rb"
require_relative "./phenomenal/relationships/relationships_manager.rb"
require_relative "./phenomenal/relationships/relationship.rb"
require_relative "./phenomenal/relationships/requirement.rb"
require_relative "./phenomenal/relationships/implication.rb"
require_relative "./phenomenal/relationships/suggestion.rb"

# Context
require_relative "./phenomenal/context/adaptation.rb"
require_relative "./phenomenal/context/context_creation.rb"
require_relative "./phenomenal/context/context.rb"
require_relative "./phenomenal/context/feature.rb"

#Manager
require_relative "./phenomenal/manager/adaptations_management.rb"
require_relative "./phenomenal/manager/contexts_management.rb"
require_relative "./phenomenal/manager/conflict_policies.rb"
require_relative "./phenomenal/manager/manager.rb"

# Viewer
require_relative "./phenomenal/viewer/graphical.rb"
require_relative "./phenomenal/viewer/textual.rb"

# DSL
require_relative "./phenomenal/relationships/dsl.rb"
require_relative "./phenomenal/viewer/dsl.rb"
require_relative "./phenomenal/dsl.rb"

# Others
require_relative "./phenomenal/logger.rb"
