require_relative '../lib/phenomenal.rb'
context :a do
  implies :b
  suggests :c
end
context :b do
  requires :a
end
feature :f1 do
  requirements_for :a, :on=>:b
  context :a do
  end
  context :c do
  end
end

feature :f2 do
  implies :f1
  
end

phen_activate_context(:f1)

phen_graphical_view
puts phen_textual_view
