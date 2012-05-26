# Define the class where all the actives relationships are
# efficiently stored
class Phenomenal::RelationshipStore
  attr_accessor :sources, :targets
  
  def initialize
    @sources = {}
    @targets = {}
  end
  
  def add(relationship)
    if @sources[relationship.source].nil?
      @sources[relationship.source] = Array.new 
    end
    @sources[relationship.source].push(relationship)
    
    if @targets[relationship.target].nil?
      @targets[relationship.target] = Array.new 
    end
    @targets[relationship.target].push(relationship)
  end
  
  def remove(relationship)
    @sources[relationship.source].delete(relationship) if @sources[relationship.source] # In case of rollback
    @targets[relationship.target].delete(relationship) if @targets[relationship.target]
  end
  
  def include?(relationship)
    if @sources[relationship.source]
      @sources[relationship.source].include?(relationship)
    else
      false
    end
  end
  
  def update_references(context)
    # Do nothing when anonymous, references are already valid
    return if context.anonymous?
    # Update sources
    set_references(@sources,context) do
      relationship.source=context
    end
    # Update targets
    set_references(@sources,context) do
      relationship.target=context 
    end
  end
  
  # Return all relationships for 'context'
  def get_for(context)
    array_for(@sources,context).concat(array_for(@targets,context))
  end
  
  private
  # Set the references for 'context' (according to 'block')
  def set_references(contexts,context,&block)
    if !contexts[context.name].nil?
      contexts[context.name].each do |relationship|
        yield
      end
      contexts[context]=contexts.delete(context.name)
    end
  end
  
  # Return an array of relationships
  def array_for(contexts,context)
    rel = contexts[context]
    if rel.nil?
      Array.new
    else
      rel
    end
  end
end
