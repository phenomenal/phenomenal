require_relative 'lib/phenomenal.rb'
class TestClass
  def print(p)
  end
end

class Phenomenal::TestDeclaration
  act_as_context :persistent

  adaptations_for TestClass
  adapt :print  do |p|
    puts p
  end
end

Phenomenal::Manager.instance.find_context("Phenomenal::TestDeclaration").activate
puts Phenomenal::Manager.instance.find_context("Phenomenal::TestDeclaration").persistent
TestClass.new.print("plop")
