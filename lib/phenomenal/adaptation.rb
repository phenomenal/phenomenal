# Represent a method adaptation for a particular context
class  Phenomenal::Adaptation
  attr_accessor :context, :klass, :method_name, :implementation, :src_file,
                :src_line
                
  def initialize(context,klass, method_name, implementation)
    @context = context
    @klass = klass
    @method_name = method_name
    @implementation = implementation
    
    # Save the source location if any, this is used to find again the adaptation
    # in a ctxt_proceed call. It always exists except for method directly
    # implemented in C -> Not a problem because these one never use ctxt_proceed
    source_location = implementation.source_location
    if source_location
      @src_file = implementation.source_location[0]
      @src_line = implementation.source_location[1]
    end
  end

  # Deploy actually the adaptation in the target class by overriding the current
  # implementation
  def deploy
    method_name = self.method_name
    implementation = self.implementation
    if instance_adaptation?
      klass.class_eval { define_method(method_name, implementation) }
    else
      klass.define_singleton_method(method_name,implementation)
    end
  end
  
  #TODO check for better implem
  #TODO we are forced to keep unBoundMethod bind code, 
  #     so allow user to use unbound meth?
  # Bind the implementation corresponding to this adaptation to 'instance' when
  # instance_method or to implementation klass when class method 
  def bind(instance,*args,&block)
    if instance_adaptation?
      if implementation.class==Proc
        implementation.phenomenal_bind(instance).call(*args,&block)
      else
        implementation.bind(instance).call(*args,&block)
      end
    else
      if implementation.class==Proc
        implementation.phenomenal_class_bind(klass).call(*args,&block)
      else
        implementation.call(*args,&block)
      end
    end
  end
  
  # True if the adapted method is an instance method
  def instance_adaptation?
    klass.instance_methods.include?(method_name)
  end
  
  #True if the adaptation concern the class n_klass and method n_method
  def concern?(klass,method_name)
    self.klass==klass && self.method_name==method_name
  end

  # String representation
  def to_s
   ":#{context.name} => #{klass.name}.#{method_name} :: #{src_file}:#{src_line}"
  end
end