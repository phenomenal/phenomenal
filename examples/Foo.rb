class Foo
  def initialize
    @inst_var = "bar"
  end
  def my_instance_method
    "Base instance(#{@inst_var})"
  end
  
  def self.my_class_method
    "Base class : #{self.name}"
  end
end
