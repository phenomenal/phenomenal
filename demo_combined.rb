require_relative "./lib/phenomenal.rb"

class Foo
  def initialize
    @inst_var = "bar"
  end
  def print
    "Base: " +@inst_var
  end
end

context :b,:c do # TODO Question: b is a feature automatically?
  adaptations_for Foo
  adapt :print do
    "B + C"
  end
end

feature :a do
  feature :b do
    context :c do 
      adaptations_for Foo
      adapt :print do
        "A + B + C"
      end
    end
  end
  
  adaptations_for Foo
  adapt :print do
    "A"
  end
end

f = Foo.new
puts f.print

activate_context :b
puts f.print
activate_context :c
activate_context :a
puts f.print
deactivate_context :a
puts f.print
deactivate_context :c
deactivate_context :b
puts f.print
activate_context :b
puts f.print
activate_context :a
puts f.print
activate_context :c
puts f.print
