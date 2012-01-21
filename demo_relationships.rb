require_relative 'lib/phenomenal.rb'
context :brussels do
  implies :belgium
end
context :belgium

activate_context(:brussels)

activate_context(:belgium)
activate_context(:belgium)
activate_context(:belgium)
activate_context(:belgium)

deactivate_context(:brussels)

puts phen_context_information(:brussels)

puts phen_context_information(:belgium)


context :brussels, :sablon do
  
end