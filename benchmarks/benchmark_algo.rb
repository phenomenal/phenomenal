require "benchmark"
require "../lib/phenomenal"

class Foo
  attr_accessor :strategy
    
  def initialize
    @strategy = Strategy0 
  end
  
  def meth
    0
  end
  
  def strategy_meth
    strategy.recieve
  end
end

LOOP_COUNT = 1000
SWITCH_COUNT = 50
CALL_COUNT = 20000#250 for crossing between if's and context's, 1000 for strategies and contexts

ifs = ""
SWITCH_COUNT.times do |i| 
  # IF'S
  ifs += "if selector==#{i} 
    return selector 
  end 
  "
  
  # Strategies
  eval("
  class Strategy#{i}
    def self.recieve
      #{i}
    end  
  end
  ")
end

Foo.class_eval "
  def if_meth(selector)
    #{ifs}
    return 0
  end
"

SWITCH_COUNT.times do  |i|
  context i.to_s.to_sym do
    adaptations_for Foo
    adapt :meth do
      i
    end
  end
end

f = Foo.new

Benchmark.bmbm do |x|
  x.report("IF's:") do 
    LOOP_COUNT.times do |i| 
      selector = i%SWITCH_COUNT
      CALL_COUNT.times {f.if_meth(selector)}
    end
  end
  x.report("Strategies")  do 
    LOOP_COUNT.times do |i| 
      f.strategy=Object.const_get("Strategy#{i%SWITCH_COUNT}")
      CALL_COUNT.times {f.strategy_meth}
    end
  end
  x.report("Contexts")  do 
    LOOP_COUNT.times do |i| 
      context = (i%SWITCH_COUNT).to_s.to_sym
      activate_context(context)
      CALL_COUNT.times {f.meth}
      deactivate_context(context)
    end
  end
end
