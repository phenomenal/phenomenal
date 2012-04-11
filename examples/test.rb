require_relative "../lib/phenomenal.rb"

class Foo
  def a
    "Foo.a"
  end
  def b
    "Foo.b"
  end
end

context :x do
  adaptations_for Foo

  adapt :a do
    "[x] a: #{proceed}"
  end

  adapt :b do
    "[x] b: #{proceed}"
  end

  context :y do
    adaptations_for Foo
    adapt :a do
      "[x,y] a: #{proceed}"
    end
  end
end

f = Foo.new
activate_context :x
activate_context :y
puts f.b
