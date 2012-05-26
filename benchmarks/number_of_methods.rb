require "benchmark"
require "bigdecimal"
require "../lib/phenomenal"


VAL_KEY = :method_count
VALUES = [0,1,10,50,100,250]

parameters = {}
parameters[:bench_count] = 1
parameters[:method_count] = 1000# Number of layers, same as greatest from VALUES
parameters[:call_count] = 1 # Number of call to the method for each value
  
#compute min,mean,max
def compute_result(bench_result)
  res = {}
  res[:method] = Array.new
  
  bench_result.each do |r|
    res[:method].push(BigDecimal.new(r[0].total.to_s))
  end
  [:method].each do |method|
    res[method] = {
      :min=>res[method].min,
      :max=>res[method].max,
      :average=>(res[method].inject(0,:+)/BigDecimal.new(res[method].length.to_s))
    }
  end
  res
end


class Foo
end

parameters[:method_count].times do |i|
  Foo.class_eval "
    def meth_#{i}
      #{i}
    end
  "
end

result = {}
VALUES.each do |val|
  parameters[VAL_KEY]=val
  bench_result = Array.new
  parameters[:method_count].times do |i|
    context :Bar do
      adaptations_for Foo
      adapt "meth_#{i}".to_sym do
        i
      end
    end
  end
  parameters[:bench_count].times do |bc|
    b= Benchmark.bmbm do |x|
      x.report("Activate same:") do 
        parameters[:method_count].times do |i|
          parameters[:call_count].times { activate_context :Bar }
        end
      end
    end
    bench_result.push(b)
  end
  c = context :Bar; while c.active?; c.deactivate; end; c.forget;
  result[val]=compute_result(bench_result)
end

# Writing files
[:method].each do |method|
  File.open("results/number_of_methods/#{VAL_KEY}/#{method}.dat", 'w') do |f| 
    f.puts "# Method: #{method}"
    f.puts "# #{parameters}"
    f.puts "# MIN MAX AVERAGE"
    result.keys.each do |k|
      f.puts "#{k}  #{result[k][method][:min]}  #{result[k][method][:max]}  #{result[k][method][:average]}"
    end
  end
end

# Generating graph
Dir.chdir("results/number_of_methods/#{VAL_KEY}")
`gnuplot algo.plot`

