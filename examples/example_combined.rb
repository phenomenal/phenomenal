require_relative "../lib/phenomenal.rb"
require "./Foo"

# Define a combined base contexts
feature :f1
context :c1
context :c2

# Define a combined context with c1 and c2
context :c1,:c2 do
  adaptations_for Foo
  adapt :my_instance_method do
    "[c1 & c2]:Adapted instance+#{proceed}"
  end
end

# Define a combined context with c2 and c3
# => auto declaration of c3
context :c2,:c3 do
  adaptations_for Foo
  adapt :my_instance_method do
    "[c2 & c3]:Adapted instance+#{proceed}"
  end
end

# Define the combined context c1 and c2 IN f1
# Use open context to add behaviour to f1
feature :f1 do
  context :c1,:c2 do 
      adaptations_for Foo
      adapt :my_instance_method do
        "[f1 & c1 & c2]:Adapted instance+#{proceed}"
      end
  end
  
  adaptations_for Foo
  adapt :my_instance_method do
    "[f1]:Adapted instance+#{proceed}"
  end
end

f = Foo.new
puts "===> Default behaviour"
puts f.my_instance_method

puts "===> :c1 context activated"
activate_context :c1
puts f.my_instance_method

puts "===> :c1 context deactivated"
deactivate_context :c1

puts "===> :c2 context activated"
activate_context :c2

puts "===> :c3 context activated -> combined c2,c3 is activated"
activate_context :c3
puts f.my_instance_method

puts "===> :c1 context activated -> combined c2,c3 and c1,c2 are activated"
activate_context :c1
puts f.my_instance_method

puts "===> :c2 context deactivated -> combined c2,c3 and c1,c2 are deactivated"
deactivate_context :c2
puts f.my_instance_method

puts "===> :c3 context deactivated -> no change"
deactivate_context :c3

puts "===> :f1 feature activated"
activate_context :f1
puts f.my_instance_method

puts "===> :c1 and c2 contexts activated"
activate_context :c1,:c2
puts f.my_instance_method


