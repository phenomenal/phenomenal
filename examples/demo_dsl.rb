require_relative 'lib/phenomenal.rb'
class Foo
  def initialize
    @inst_var = "bar"
  end
  def print
    "Base: " +@inst_var
  end
end

context :Test do 
   implies :plop # TODO what if the feature is already active?
  
  adaptations_for Foo
  adapt :print do 
    phen_proceed + "ADAPT"
  end
end

f = Foo.new
puts f.print

phen_activate_context(:Test)
puts f.print

phen_deactivate_context(:Test)
puts f.print

