# Load the gem files in the system
module Phenomenal end
#Relationships
require_relative "./phenomenal/relationships/context_relationships.rb"
require_relative "./phenomenal/relationships/relationships_store.rb"
require_relative "./phenomenal/relationships/relationships_manager.rb"
require_relative "./phenomenal/relationships/relationship.rb"
require_relative "./phenomenal/relationships/requirement.rb"
require_relative "./phenomenal/relationships/implication.rb"
require_relative "./phenomenal/relationships/suggestion.rb"

# Core
require_relative "./phenomenal/adaptation.rb"
require_relative "./phenomenal/conflict_policies.rb"
require_relative "./phenomenal/context.rb"
require_relative "./phenomenal/feature.rb"
require_relative "./phenomenal/logger.rb"
require_relative "./phenomenal/manager.rb"
require_relative "./phenomenal/proc.rb"

# DSL
require_relative "./phenomenal/relationships/dsl.rb"
require_relative "./phenomenal/dsl.rb"
