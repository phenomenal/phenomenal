require_relative 'lib/phenomenal.rb'
class TestClass
  def print(p)
  end
end

class Phenomenal::TestDeclaration
  act_as_context

  adaptations_for TestClass
  adapt :print  do |p|
    puts p
  end
end

Phenomenal::Manager.instance.find_context("Phenomenal::TestDeclaration").activate
TestClass.new.print("plop")
