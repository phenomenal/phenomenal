module Phenomenal::Relationships
  attr_accessor  :required, :implied, :suggested, :activated_suggested, 
      :is_implied, :is_required
  
  def initialize_relationships
    @implied = Array.new
    @is_implied = {}
    @required = Array.new
    @is_required = {}
    @suggested = Array.new
    @activated_suggested={}
  end
  
  # =========== Requires  =========== 
  def requires(context, *contexts)
    contexts.push context
    contexts.each do |context_name|
      if !required.include?(context_name)
        required.push(context_name)
      end
    end
  end
  
  def check_requirements
    required.each do |context_name|
      context = manager.find_context(context_name)
      if context.active?
        context.is_required[self.__id__] = self
      else
        Phenomenal::Logger.instance.error(
          "Error: Required context #{context_name} not active."
        )
      end
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
  def implies(context, *contexts)
    contexts.push(context)
    contexts.each do |context_name|
      if !implied.include?(context_name)
        implied.push(context_name)
      end
    end
  end

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
  def suggests(context, *contexts)
    contexts.push context
    contexts.each do |context_name|
      if !suggested.include?(context_name)
        suggested.push(context_name)
      end
    end
  end
  
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
