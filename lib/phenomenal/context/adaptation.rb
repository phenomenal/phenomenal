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

  # Bind the implementation corresponding to this adaptation to 'instance' when
  # instance_adaptation or to implementation class when class method 
  def bind(instance,*args,&block)
    target = instance_adaptation? ? instance : klass
    if implementation.is_a?(Proc)
      args.push(block)
      target.instance_exec(*args,&implementation)
    else
      implementation.bind(target).call(*args,&block)
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
    method = get_original_method
    if method.arity != implementation.arity
      Phenomenal::Logger.instance.error(
        "Illegal adaptation for context #{context},the adaptation "+ 
        "have to keep the original method arity for method: " +
        "#{klass.name}.#{method_name}: (#{method.arity} instead of " +
        "#{implementation.arity})." 
      )
    elsif klass.instance_methods.include?(method_name) ^ instance_adaptation?
      Phenomenal::Logger.instance.error(
        "Illegal adaptation for context: #{context}" +
        " for #{klass.name}.#{method_name}, type mismatch"
      )
    end
  end
  
  def get_original_method
    begin
      if instance_adaptation?
        method = klass.instance_method(method_name)
      else
        method = klass.method(method_name)
      end
    rescue NameError
      Phenomenal::Logger.instance.error(
        "Illegal adaptation for context #{context},a method with "+
        "name: #{method_name} should exist in class #{klass.name} to "+ 
        "be adapted."
      )
    end
    method
  end
end
