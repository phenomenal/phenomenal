require_relative 'lib/phenomenal.rb'
class Foo
  def initialize
    @inst_var = "bar"
  end
  def print
    "Base: " +@inst_var
  end
end

pnml_define_context(:demo)
pnml_add_adaptation(:demo, Foo, :print) do
  pnml_proceed + " adaptation: "+ @inst_var
end

f = Foo.new
puts f.print

pnml_activate_context(:demo)
puts f.print

pnml_deactivate_context(:demo)
puts f.print

