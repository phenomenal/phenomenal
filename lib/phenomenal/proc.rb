# Add methods to Proc classe
class Proc
  # Define a bind method on Proc object,
  # This allow to execute a Proc as it was an instance method of reciever
  #  --> used for composition of instance methods adaptations
  # Src: http://www.ruby-forum.com/topic/173699
  def phenomenal_bind(receiver)
    block, time = self, Time.now
    (class << receiver; self end).class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}-#{rand(100000)}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(receiver)
  end

  # Define a bind_class method on Proc object,
  # This allow to execute a Proc as it was an class method of klass
  # --> used for composition of class methods adaptations
  def phenomenal_class_bind(klass)
    block, time = self, Time.now
      method_name = "__bind_#{time.to_i}_#{time.usec}-#{rand(100000)}"
      method = nil
      klass.instance_eval do
        define_singleton_method(method_name, &block)
        method = method(method_name)
        (class << self; self end).instance_eval do
          remove_method(method_name)
        end
      end
      method
  end
end
