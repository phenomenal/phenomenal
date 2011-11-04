require_relative 'lib/phenomenal.rb'
class TestClass
  def print(p)
  end
end
class Phenomenal::TestDeclaration < Phenomenal::Declaration
  def self.test
    pnml_def(TestClass, :print) do |p|
      puts p
    end
    Phenomenal::Manager.instance.find_context(self.class.name).activate
  end
end

Phenomenal::TestDeclaration.test
TestClass.new.print("plop")