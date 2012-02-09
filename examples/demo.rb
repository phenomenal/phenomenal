require_relative 'lib/phenomenal.rb'
class Foo
  def initialize
    @inst_var = "bar"
  end
  def print
    "Base: " +@inst_var
  end
end

phen_define_context(:demo)
phen_add_adaptation(:demo, Foo, :print) do
  phen_proceed + " adaptation: "+ @inst_var
end

f = Foo.new
puts f.print

phen_activate_context(:demo)
puts f.print

phen_deactivate_context(:demo)
puts f.print

