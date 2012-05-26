require "benchmark"
require "bigdecimal"
require "../lib/phenomenal"


VAL_KEY = :layers_count
VALUES = [0,1,2,3,4,5,10,50,100]

parameters = {}
parameters[:bench_count] = 20
parameters[:layers_count] = 100 # Number of layers, same as greatest from VALUES
parameters[:call_count] = 1 # Number of call to the method for each value
  
#compute min,mean,max
def compute_result(bench_result)
  res = {}
  res[:proceed] = Array.new
  
  bench_result.each do |r|
    res[:proceed].push(BigDecimal.new(r[0].total.to_s))
  end
  [:proceed].each do |method|
    res[method] = {
      :min=>res[method].min,
      :max=>res[method].max,
      :average=>(res[method].inject(0,:+)/BigDecimal.new(res[method].length.to_s))
    }
  end
  res
end


class Foo
  def meth
    0
  end
end

File.open("proceed_context_definitions.rb", 'w') do |f| 
  (1..(parameters[:layers_count]+1)).each do |i|
   f.puts "context #{i}.to_s.to_sym do"
   f.puts "  adaptations_for Foo"
   f.puts "   adapt :meth do"
   f.puts "     proceed"
   f.puts "   end"
   f.puts " end"
  end
end

load "proceed_context_definitions.rb"

result = {}
VALUES.each do |val|
  parameters[VAL_KEY]=val
  f = Foo.new
  bench_result = Array.new
  parameters[:bench_count].times do |bc|
    (parameters[:layers_count]+1).times {|i| activate_context(i.to_s.to_sym) if i>0 } 
    b= Benchmark.bmbm do |x|
      x.report("Proceed:") do 
        parameters[:call_count].times { f.meth }
      end
    end
    (parameters[:layers_count]+1).times {|i| deactivate_context(i.to_s.to_sym) if i>0 } 
    bench_result.push(b)
  end
  result[val]=compute_result(bench_result)
end

# Writing files
[:proceed].each do |method|
  File.open("results/proceed/#{VAL_KEY}/#{method}.dat", 'w') do |f| 
    f.puts "# Method: #{method}"
    f.puts "# #{parameters}"
    f.puts "# MIN MAX AVERAGE"
    result.keys.each do |k|
      f.puts "#{k}  #{result[k][method][:min]}  #{result[k][method][:max]}  #{result[k][method][:average]}"
    end
  end
end

# Generating graph
Dir.chdir("results/proceed/#{VAL_KEY}")
`gnuplot algo.plot`

