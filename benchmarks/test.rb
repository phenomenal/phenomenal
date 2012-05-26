require "../lib/phenomenal"

class Foo
  def meth
    1
  end
end

50.times do |i|
 context i.to_s.to_sym do
   adaptations_for Foo
    adapt :meth do
      proceed+1
    end
  end

  activate_context context i.to_s.to_sym
end

f = Foo.new

puts f.meth
