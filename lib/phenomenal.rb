require 'singleton'
# Load the gem files in the system
module Phenomenal 
  module Viewer end
end
#Error
require_relative "./phenomenal/error.rb"

#Relationships
require_relative "./phenomenal/relationship/context_relationships.rb"
require_relative "./phenomenal/relationship/feature_relationships.rb"
require_relative "./phenomenal/relationship/relationship_store.rb"
require_relative "./phenomenal/relationship/relationship_manager.rb"
require_relative "./phenomenal/relationship/relationship.rb"
require_relative "./phenomenal/relationship/requirement.rb"
require_relative "./phenomenal/relationship/implication.rb"
require_relative "./phenomenal/relationship/suggestion.rb"

# Context
require_relative "./phenomenal/context/adaptation.rb"
require_relative "./phenomenal/context/context_creation.rb"
require_relative "./phenomenal/context/context.rb"
require_relative "./phenomenal/context/feature.rb"

#Manager
require_relative "./phenomenal/manager/adaptation_management.rb"
require_relative "./phenomenal/manager/context_management.rb"
require_relative "./phenomenal/manager/conflict_policies.rb"
require_relative "./phenomenal/manager/manager.rb"

# Viewer
require_relative "./phenomenal/viewer/graphical.rb"
require_relative "./phenomenal/viewer/textual.rb"

# DSL
require_relative "./phenomenal/relationship/dsl.rb"
require_relative "./phenomenal/viewer/dsl.rb"
require_relative "./phenomenal/dsl.rb"
