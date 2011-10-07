require 'phenomenal'
class Foo
  def initialize
    @inst_var = "bar"
  end
  def print
    "Base: " +@inst_var
  end
end

ctxt_def(:demo)
ctxt_add_adaptation(:demo, Foo, :print) do
  ctxt_proceed + " adaptation: "+ @inst_var
end

f = Foo.new
puts f.print

ctxt_activate(:demo)
puts f.print

ctxt_deactivate(:demo)
puts f.print

