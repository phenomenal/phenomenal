# Represent a method adaptation for a particular context
class  Phenomenal::Adaptation
  attr_accessor :context, :klass, :method_name, :implementation, :src_file,
                :src_line,:instance_adaptation
  alias_method :instance_adaptation?, :instance_adaptation
                
  def initialize(context,klass, method_name,instance_adapatation,implementation)
    @context = context
    @klass = klass
    @method_name = method_name
    @implementation = implementation
    @instance_adaptation=instance_adapatation
    check_validity
    # Save the source location if any, this is used to find again the adaptation
    # in a proceed call. It always exists except for method directly
    # implemented in C -> Not a problem because these one never use proceed
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
  
  # IMPROVE try to find a better implementation
  # Bind the implementation corresponding to this adaptation to 'instance' when
  # instance_adaptation or to implementation class when class method 
  def bind(instance,*args,&block)
    if instance_adaptation?
      if implementation.class==Proc
        args.push(block)
        instance.instance_exec(*args,&implementation)
      else
        implementation.bind(instance).call(*args,&block)
      end
    else
      if implementation.class==Proc
        args.push(block)
        klass.instance_exec(*args,&implementation)
      else
        implementation.call(*args,&block)
      end
    end
  end
  
  #True if the adaptation concern the class n_klass and method n_method
  def concern?(klass,method_name,instance_adaptation)
    self.klass==klass && 
    self.method_name==method_name && 
    self.instance_adaptation==instance_adaptation
  end
    
  # String representation
  def to_s
   ":#{context.name} => #{klass.name}.#{method_name} :: #{src_file}:#{src_line}"
  end
  
  private
  def check_validity
    if klass.instance_methods.include?(method_name) && !instance_adaptation? ||
      !klass.instance_methods.include?(method_name) &&  instance_adaptation?
      Phenomenal::Logger.instance.error(
        "Illegal adaptation for context: #{context}" +
        " for #{klass.name}.#{method_name}, type mismatch"
      )
    end
  end
end
