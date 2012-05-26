require "benchmark"
require "bigdecimal"
require "../lib/phenomenal"

# Uncomment value to test
#------------------------

#VAL_KEY = :call_count
#VALUES = [1,100,250,500,750,1000,1500,2000,2500,3000,4000,5000,10000,20000,30000,40000,50000]

#VAL_KEY = :switch_count
#VALUES = [1,10,20,50,100,500] 
# WARNING => parameters[:change_count] & parameters[:switch_count] must have same value as greatest val of VALUE

VAL_KEY = :change_count
VALUES = [1,10,20,50,100,500,1000]



parameters = {}
parameters[:bench_count] = 1 # Number of times the tests are run -> to avoid random variations
parameters[:change_count] = 50 # Number of changes of behavior
parameters[:switch_count] = 50 # Number of Contexts/Strategies/IF'S
parameters[:call_count] = 20000 # Number of call to the method for each value
  # ~250 for crossing between if's and context's, ~1000 for strategies and contexts
  
#compute min,mean,max
def compute_result(bench_result)
  res = {}
  res[:ifs] = Array.new
  res[:strategies] = Array.new
  res[:contexts] = Array.new
  
  bench_result.each do |r|
    res[:ifs].push(BigDecimal.new(r[0].total.to_s))
    res[:strategies].push(BigDecimal.new(r[1].total.to_s))
    res[:contexts].push(BigDecimal.new(r[2].total.to_s))
  end
  [:ifs,:strategies,:contexts].each do |method|
    res[method] = {
      :min=>res[method].min,
      :max=>res[method].max,
      :average=>(res[method].inject(0,:+)/BigDecimal.new(res[method].length.to_s))
    }
  end
  res
end


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
def set_modes(parameters)
  phen_defined_contexts.each {|c| (while c.active?; c.deactivate; end; c.forget;) if c!=phen_default_feature }
  
  ifs = "if selector==0 
          return 0 
          "
  parameters[:switch_count].times do |i| 
    # IF'S
    if i!=0
      ifs += "elsif selector==#{i} 
              return #{i}  
            " 
    end
    
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

  ifs += "else 
              return 0  
          end"

  # Define IF's method
  Foo.class_eval "
    def if_meth(selector)
      #{ifs}
      return 0
    end
  "
end

result = {}
VALUES.each do |val|
  parameters[VAL_KEY]=val
  set_modes(parameters)
  f = Foo.new
  bench_result = Array.new
  parameters[:bench_count].times do |bc|
    b= Benchmark.bmbm do |x|
      x.report("IF's:") do 
        parameters[:change_count].times do |i| 
          selector = i%parameters[:switch_count]
          parameters[:call_count].times {f.if_meth(selector)}
        end
      end
      x.report("Strategies")  do 
        parameters[:change_count].times do |i| 
          f.strategy=Object.const_get("Strategy#{i%parameters[:switch_count]}")
          parameters[:call_count].times {f.strategy_meth}
        end
      end
      x.report("Contexts")  do 
        parameters[:change_count].times do |i| 
          context = (i%parameters[:switch_count]).to_s.to_sym
          activate_context(context)
          parameters[:call_count].times {f.context_meth}
          deactivate_context(context)
        end
      end
    end
    bench_result.push(b)
  end
  result[val]=compute_result(bench_result)
end

# Writing files
[:ifs,:strategies,:contexts].each do |method|
  File.open("results/algo/#{VAL_KEY}/#{method}.dat", 'w') do |f| 
    f.puts "# Method: #{method}"
    f.puts "# #{parameters}"
    f.puts "# MIN MAX AVERAGE"
    result.keys.each do |k|
      f.puts "#{k}  #{result[k][method][:min]}  #{result[k][method][:max]}  #{result[k][method][:average]}"
    end
  end
end

# Generating graph
Dir.chdir("results/algo/#{VAL_KEY}")
`gnuplot algo.plot`

