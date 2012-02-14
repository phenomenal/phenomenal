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
  suggests :c2
  suggests :c3
end

context :c2 do
  requires :c3
end

context :c3

feature :f1 do
  requirements_for :c1, :on=>:c2
  context :c1
  context :c3
end

feature :f2 do
  implies :f1
end

puts "===> Contexts defined + graph generated at example_relationships.png"
puts show_active_contexts
Phenomenal::Viewer::Graphical.new("example_relationships.png").generate
#puts Phenomenal::Viewer::Textual.new.generate

puts "===> :c1 context activated"
activate_context :c1
puts show_active_contexts

puts "===> :c1 context deactivated"
deactivate_context :c1
puts show_active_contexts

puts "===> :c3 context activated"
activate_context :c3
puts show_active_contexts

puts "===> :c2 context activated"
activate_context :c2
puts show_active_contexts

puts "===> :f2 feature activated"
activate_context :f2
puts show_active_contexts

