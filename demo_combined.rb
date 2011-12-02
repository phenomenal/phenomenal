require_relative "./lib/phenomenal.rb"

class Foo
  def initialize
    @inst_var = "bar"
  end
  def print
    "Base: " +@inst_var
  end
end

context :a
context :b
context :c

context :a,:b,:c do 
  adaptations_for Foo
  adapt :print do
    "COMBINED"
  end
end

activate_context :a
