require_relative '../lib/phenomenal.rb'

def show_active_contexts
  str=""
  phen_defined_contexts.each do |context|
    if context.active?
      str+="#{context.to_s} "
    end
  end
  str
end

context :c1 do
  implies :c2
  suggests :c3
end

context :c2 do
  requires :c1
end

feature :f1 do
  requirements_for :c1, :on=>:c2
  context :c1 do
  end
  context :c3 do
  end
end

feature :f2 do
  implies :f1
end

puts "===> Contexts defined"
puts show_active_contexts

puts "===> :c1 context activated"
activate_context :c1
puts show_active_contexts

puts "===> :c1 context deactivated"
deactivate_context :c1
puts show_active_contexts

puts "===> :c2 context activated"
activate_context :c2
puts show_active_contexts

Phenomenal::Viewer::Graphical.new("demo_relationships.png").generate
#puts Phenomenal::Viewer::Textual.new.generate
