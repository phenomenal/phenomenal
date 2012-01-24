class Phenomenal::Feature < Phenomenal::Context
  attr_accessor  :required, :implied, :suggested
  
  def initialize(name=nil, priority=nil,manager=nil)
    super(name, priority,manager)
    @implied = {} # Hash of array with one array for each context
    @required = {}
    @suggested = {}
  end
  
  # =========== DSL =============

  def feature(feature,*features, &block)
    f = Phenomenal::Feature.create(self,feature,*features,true,&block)
    f.parent = self
    f
  end
  alias_method :phen_feature,:feature
  
  def requirements_for(context_name, new_requirements)
    if !new_requirements[:on].is_a? Array
      new_requirements[:on]=Array.new.push(new_requirements[:on]) 
    end
    
    context_id = manager.linked_context_id(context_name)
    
    new_requirements[:on].each do |requirement_name|
      required[context_id] = Array.new if required[context_id].nil?
      context_requirements =  required[context_id]
      requirement_id = manager.linked_context_id(requirement_name)
      if !context_requirements.include?(requirement_id)
        context_requirements.push(requirement_id)
      end
    end
    puts "DEFINITION  #{self.required} for #{context_name} in #{self}"
  end
  
  def implications_for(context_name, new_implications)
    if !new_implications[:on].is_a? Array
      new_implications[:on]=Array.new.push(new_implications[:on]) 
    end
    new_implications[:on].each do |implication_name|
      implied[context_name] = Array.new if implied[context_name].nil?
      context_implications =  implied[context_name]
      if !context_implications.include?(implication_name)
        context_implications.push(implication_name)
      end
    end
  end
  
  def suggestions_for(context_name, new_suggestions)
    if !new_suggestions[:on].is_a? Array
      new_suggestions[:on]=Array.new.push(new_suggestions[:on]) 
    end
    new_suggestions[:on].each do |suggestion_name|
      suggested[context_name] = Array.new if suggested[context_name].nil?
      context_suggestions =  suggested[context_name]
      if !context_suggestions.include?(suggestion_name)
        context_suggestions.push(suggestion_name)
      end
    end
  end

  
  # =========== Requires  =========== 
  
  # source context is a context instance  
  def activate_requirements(source_context)
    puts "ACTIVATION  #{self.required} for #{source_context} in #{self}"
    activated = {}
    if required[manager.linked_contexts[source_context]].nil?
      return
    end
    begin 
      manager.shared_contexts[source_context].each do |shared_context|
        activated[shared_context] = Array.new
        
        required[manager.linked_contexts[shared_context]].each do |context_id|
         # context = manager.find_context(context_name)
          if context.active?
            manager.linked_contexts[context_id].is_required[source_context] = source_context
            activated[shared_context].push(context)
          else
            Phenomenal::Logger.instance.error(
              "Error: Required context #{context_name} not active."
            )    
          end
        end
      end
    rescue Phenomenal::Error  # Rollback
      activated.keys.each do |k|
        activated[k].each do |context|
          context.is_required.delete(source_context)
        end
      end
      raise
    end
  end
  
  def deactivate_requirements
    deactivated = Array.new
    begin    
      if self.activation_count<=1
        is_required.each do |context_id,context|
          while context.active?
            context.deactivate(self)
            deactivated.push(context)
          end
        end
        is_required.clear
      end
    rescue Phenomenal::Error => error
      deactivated.reverse.each do |context|
        context.activate
      end
      Phenomenal::Logger.instance.error(
        "Error: Requirements not satisfied for deactivation of  
        context #{name} : \n #{error}"
      )
    end
  end

  # ===========  Implies  =========== 
  def activate_implications
    activated = Array.new
    begin
      implied.each do |context_name|
        context  = manager.find_context(context_name)
        context.activate
        context.is_implied[self.__id__] = self
        activated.push(context)
      end
    rescue Phenomenal::Error => error
      #Rollback
      activated.reverse.each do |context|
        context.deactivate(self)
      end
      Phenomenal::Logger.instance.error(
          "Error: Implication not satisfied for context #{name} : \n#{error}"
        )
    end
  end
  
  def deactivate_implications(caller_context=nil)
    deactivated = Array.new
    begin
      implied.each do |context_name|
        context  = manager.find_context(context_name)
        if self.activation_count<=1
          context.is_implied.delete(self.__id__)
        end
        context.deactivate(self) if context!=caller_context
        
        deactivated.push(context)
      end
      is_implied.each do |context_id,context|
        context.deactivate(self)
        deactivated.push(context)
      end
    rescue Phenomenal::Error => error
      #Rollback
      deactivated.reverse.each do |context|
        context.activate
        context.is_implied[self.__id__]=self
      end
      Phenomenal::Logger.instance.error(
          "Error: Forbidden deactivation due to implication not "+
          "satisfied for context #{name} : \n -- #{error}"
        )
    end
    is_implied.each do |context|
      if !context.active?
        is_implied.delete(context.__id__)
      end
    end
  end
  
  # ===========  Suggests  =========== 
  def activate_suggestions
    begin
      suggested.each do |context_name|
        context  = manager.find_context(context_name)
        context.activate
        # Save realy activated contexts for later deactivation
        activated = activated_suggested[context.__id__]
        if activated
          activated_suggested[context.__id__]=[context,activated[1]+1] 
        else
          activated_suggested[context.__id__]=[context,1] 
        end
      end
    rescue Phenomenal::Error # Don't care of error in case of suggests
    end
  end
  
  def deactivate_suggestions
    activated_suggested.each do |k,v|
      begin
        context  = manager.find_context(v[0])
        context.deactivate(self)
        activated = activated_suggested[k]
        activated_suggested[k]=[context,activated[1]-1]
        if activated[1]==0
          activated_suggested.delete(k)
        end
      rescue Phenomenal::Error # Don't care of error in case context was forgeted
        activated_suggested.delete(k)
      end
    end
  end
  
end
