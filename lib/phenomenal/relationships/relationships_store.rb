class Phenomenal::RelationshipsStore
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
  
  
  def update_references(context)
    # Do nothing when anonymous, references are already valid
    return if context.anonymous?
    # Update sources 
    @sources[context.name].each do |relationship|
      relationship.source=context
    end
    @sources[context]=@source.delete(context.name)
    # Update targets
    @targets[context.name].each do |relationship|
      relationship.target=context
    end
    @targets[context]=@targets.delete(context.name)
  end
  
  def get_for(context)
    get_for_source(context).concat(get_for_target(context))
  end
  
  private
  # Return an array of relationships
  def get_for_source(source)
    rel = @sources[source]
    if rel.nil?
      Array.new
    else
      rel
    end
  end
  
  # Return an array of relationships
  def get_for_target(target)
    rel = @targets[target]
    if rel.nil?
      Array.new
    else
      rel
    end
  end
end
