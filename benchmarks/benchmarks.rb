#                              user     system      total        real
#Default:                  0.180000   0.000000   0.180000 (  0.181481)
#Adapted                   0.180000   0.000000   0.180000 (  0.176527)
#Adapted with activation  20.840000   0.000000  20.840000 ( 20.902801)
#Proceed                  30.820000   0.000000  30.820000 ( 30.939178)


require "benchmark"
require "../lib/phenomenal"

class Foo
  def meth
    1
  end
  
  def meth_proceed
    2
  end
end

context :Test do
  adaptations_for Foo
  adapt :meth do
    1
  end
  
  adapt :meth_proceed do
    proceed
  end
end

f = Foo.new
LOOP_COUNT = 1000000

Benchmark.bmbm do |x|
  x.report("Default:") do 
      LOOP_COUNT.times {f.meth}
  end
  activate_context :Test
  x.report("Adapted")  do 
      LOOP_COUNT.times {f.meth}
  end
 deactivate_context :Test
  x.report("Adapted with activation")  do 
      LOOP_COUNT.times do
        activate_context :Test
        f.meth
        deactivate_context :Test
      end
  end
  activate_context :Test
  x.report("Proceed")  do 
      LOOP_COUNT.times {f.meth_proceed}
  end
end
