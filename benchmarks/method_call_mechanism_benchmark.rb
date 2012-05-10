require "benchmark"

class A
  def test
    1
  end
end

p = Proc.new{ 1 }

um = A.instance_method(:test)
a = A.new

LOOP_COUNT = 1000000
Benchmark.bmbm do |x|
  x.report("Default:") do 
      LOOP_COUNT.times {a.test}
  end
  x.report("Bind meth")  do 
      LOOP_COUNT.times {um.bind(a).call}
  end
  x.report("Bind proc")  do 
      LOOP_COUNT.times {a.instance_exec(&p)}
  end
end
