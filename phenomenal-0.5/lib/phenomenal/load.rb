#Load the ctxt_* primitives as top level methods
module Kernel
  include CopRuby
end

# Change Proc object when the module is required
class Proc
  # Define a bind method on Proc object,
  # This allow to execute a Proc as it was an instance method of reciever
  #  --> used for composition of instance methods adaptations
  # Src: http://www.ruby-forum.com/topic/173699
  def bind(receiver)
    block, time = self, Time.now
    (class << receiver; self end).class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(receiver)
  end

  # Define a bind_class method on Proc object,
  # This allow to execute a Proc as it was an class method of klass
  # --> used for composition of class methods adaptations
  def bind_class(klass)
    block, time = self, Time.now
      method_name = "__bind_#{time.to_i}_#{time.usec}"
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

