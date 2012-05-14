require "benchmark"
require "../lib/phenomenal"

LOOP_COUNT = 1 # Number of times the tests are run -> to avoid random variations
CHANGE_COUNT = 1000 # Number of changes of behavior
SWITCH_COUNT = 50 # Number of Contexts/Strategies/IF'S
CALL_COUNT = 20000 # Number of call to the method for each value
  # ~250 for crossing between if's and context's, ~1000 for strategies and contexts

class Foo
  attr_accessor :strategy
    
  def initialize
    @strategy = Strategy0 
  end
  
  def strategy_meth
    strategy.recieve
  end
  
  def context_meth
    0
  end
end


# Generate IF'S, Strategies and Context's
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
  
  # Contexts definition
  context i.to_s.to_sym do
    adaptations_for Foo
    adapt :context_meth do
      i
    end
  end
end

# Define IF's method
Foo.class_eval "
  def if_meth(selector)
    #{ifs}
    return 0
  end
"

f = Foo.new

Benchmark.bmbm do |x|
  x.report("IF's:") do 
    LOOP_COUNT.times do
      CHANGE_COUNT.times do |i| 
        selector = i%SWITCH_COUNT
        CALL_COUNT.times {f.if_meth(selector)}
      end
    end
  end
  x.report("Strategies")  do 
    LOOP_COUNT.times do
      CHANGE_COUNT.times do |i| 
        f.strategy=Object.const_get("Strategy#{i%SWITCH_COUNT}")
        CALL_COUNT.times {f.strategy_meth}
      end
    end
  end
  x.report("Contexts")  do 
    LOOP_COUNT.times do
      CHANGE_COUNT.times do |i| 
        context = (i%SWITCH_COUNT).to_s.to_sym
        activate_context(context)
        CALL_COUNT.times {f.context_meth}
        deactivate_context(context)
      end
    end
  end
end
