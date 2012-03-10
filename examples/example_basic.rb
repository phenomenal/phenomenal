require "../lib/phenomenal"
require "./Foo"

context :demo do 
  adaptations_for Foo
  adapt :my_instance_method do
    "Adapted instance+#{proceed}"
  end
  adapt_class :my_class_method do
    "Adapted class+#{proceed}"
  end
end

f = Foo.new
puts "===> Default behaviour"
puts f.my_instance_method
puts Foo.my_class_method

puts "===> :demo context activated"
activate_context(:demo)
puts f.my_instance_method
puts Foo.my_class_method

puts "===> :demo context deactivated"
deactivate_context(:demo)
puts f.my_instance_method
puts Foo.my_class_method

