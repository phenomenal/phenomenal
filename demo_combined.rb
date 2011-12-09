require_relative "./lib/phenomenal.rb"

class Foo
  def initialize
    @inst_var = "bar"
  end
  def print
    "Base: " +@inst_var
  end
end
feature :a
context :b
context :c

context :b,:c do # TODO Question: b is a feature automatically?
  adaptations_for Foo
  adapt :print do
    "B + C"
  end
end

context :b,:e do # TODO Question: b is a feature automatically?
  adaptations_for Foo
  adapt :print do
    "B + E"
  end
end

feature :a do
  context :b,:c do 
      adaptations_for Foo
      adapt :print do
        "A + B + C"
      end
  end
  
  adaptations_for Foo
  adapt :print do
    "A"
  end
end

feature :a, :d

f = Foo.new
puts "============= INIT"
puts f.print

activate_context :a
puts "============= A"
puts f.print

deactivate_context :a

activate_context :b
activate_context :c
puts "=============B+C"
puts f.print

activate_context :a
puts "============= A+B+C"
puts f.print

deactivate_context :a
puts "============= B+C"
puts f.print

deactivate_context :c
puts "============= DEFAULT"
puts f.print
deactivate_context :b
puts "============= DEFAULT"
puts f.print


activate_context :c
activate_context :b
activate_context :a



puts "============= A+B+C"
puts f.print

deactivate_context :b
puts "============= A"
puts f.print

deactivate_context :c
activate_context :e
activate_context:b
puts "============= A"
puts f.print

puts ""
puts "Contexts"
phen_defined_contexts.each do |c|
  puts "#{c.class.name}  | #{c.information[:name]|| "?"} | #{c.information[:activation_age]}  | #{c.information[:adaptations]} | #{c.information[:active]}"
end

