require "benchmark"
require "bigdecimal"
require "../lib/phenomenal"


VAL_KEY = :layers_count
VALUES = [0,1,10,50,100,250]

parameters = {}
parameters[:bench_count] = 10
parameters[:layers_count] = 500# Number of layers, same as greatest from VALUES
parameters[:call_count] = 1 # Number of call to the method for each value
  
#compute min,mean,max
def compute_result(bench_result)
  res = {}
  res[:same_method] = Array.new
  res[:different_method] = Array.new
  
  bench_result.each do |r|
    res[:same_method].push(BigDecimal.new(r[0].total.to_s))
    res[:different_method].push(BigDecimal.new(r[1].total.to_s))
  end
  [:same_method,:different_method].each do |method|
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

parameters[:layers_count].times do |i|
  context i.to_s.to_sym do
    adaptations_for Foo
    adapt :meth do
      i
    end
  end
end

parameters[:layers_count].times do |i|
  Foo.class_eval "
    def meth_#{i}
      0
    end
  "
  context (i+parameters[:layers_count]).to_s.to_sym do
    adaptations_for Foo
    adapt "meth_#{i}".to_sym do
      i
    end
  end
end
puts phen_defined_contexts

result = {}
VALUES.each do |val|
  parameters[VAL_KEY]=val
  bench_result = Array.new
  parameters[:bench_count].times do |bc|
    b= Benchmark.bmbm do |x|
      x.report("Activate same:") do 
        parameters[:layers_count].times do |i|
          parameters[:call_count].times { activate_context i.to_s.to_sym  }
        end
      end
      phen_defined_contexts.each {|c| (while c.active?; c.deactivate; end;) if c!=phen_default_feature }
      x.report("Activate different:") do 
        parameters[:layers_count].times do |i|
          parameters[:call_count].times { activate_context (i+parameters[:layers_count]).to_s.to_sym  }
        end
      end
    end
    phen_defined_contexts.each {|c| (while c.active?; c.deactivate; end;) if c!=phen_default_feature }
    bench_result.push(b)
  end
  result[val]=compute_result(bench_result)
end

# Writing files
[:same_method,:different_method].each do |method|
  File.open("results/number_of_adaptations/#{VAL_KEY}/#{method}.dat", 'w') do |f| 
    f.puts "# Method: #{method}"
    f.puts "# #{parameters}"
    f.puts "# MIN MAX AVERAGE"
    result.keys.each do |k|
      f.puts "#{k}  #{result[k][method][:min]}  #{result[k][method][:max]}  #{result[k][method][:average]}"
    end
  end
end

# Generating graph
Dir.chdir("results/number_of_adaptations/#{VAL_KEY}")
`gnuplot algo.plot`

