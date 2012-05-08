#ruby profiling.rb -r profile
# %   cumulative   self              self     total
# time   seconds   seconds    calls  ms/call  ms/call  name
# 11.48     0.07      0.07     2000     0.04     0.07  Array#sort!
# 11.48     0.14      0.07     2000     0.04     0.08  Array#each
#  8.20     0.19      0.05     4000     0.01     0.02  Phenomenal::Adaptation#concern?
#  8.20     0.24      0.05     1000     0.05     0.53  Phenomenal::Manager#proceed
#  8.20     0.29      0.05     1000     0.05     0.60  Kernel.phen_proceed
#  8.20     0.34      0.05     1000     0.05     0.06  Phenomenal::Adaptation#bind
#  6.56     0.38      0.04     1000     0.04     0.05  Phenomenal::Manager#parse_stack
#  6.56     0.42      0.04     1000     0.04     0.25  Phenomenal::Manager#sorted_adaptations_for
#  4.92     0.45      0.03     4000     0.01     0.01  Symbol#==
#  4.92     0.48      0.03     1000     0.03     0.06  Phenomenal::Manager#conflict_policy
#  3.28     0.50      0.02     1000     0.02     0.09  Phenomenal::Manager#relevant_adaptations
#  3.28     0.52      0.02     2000     0.01     0.01  Phenomenal::Context#age
#  1.64     0.53      0.01     1000     0.01     0.16  Phenomenal::Manager#find_adaptation
#  1.64     0.54      0.01     1000     0.01     0.01  UnboundMethod#bind
#  1.64     0.55      0.01     5000     0.00     0.00  Fixnum#<=>
#  1.64     0.56      0.01     1000     0.01     0.03  Phenomenal::ConflictPolicies.age_conflict_policy
#  1.64     0.57      0.01     1000     0.01     0.01  String#to_i
#  1.64     0.58      0.01     1000     0.01     0.01  Kernel.caller
#  1.64     0.59      0.01     1000     0.01     0.01  Array#find_index
#  1.64     0.60      0.01     1000     0.01     0.01  Phenomenal::Manager#instance
#  1.64     0.61      0.01        1    10.00   610.00  Integer#times
#  0.00     0.61      0.00     1000     0.00     0.00  Foo#meth_proceed
#  0.00     0.61      0.00     1000     0.00     0.00  Method#call
#  0.00     0.61      0.00     1000     0.00     0.00  Kernel.class
#  0.00     0.61      0.00     1000     0.00     0.00  Array#select
#  0.00     0.61      0.00     1000     0.00     0.00  String#scan
#  0.00     0.61      0.00     1000     0.00     0.14  Enumerable.find_all
#  0.00     0.61      0.00        1     0.00   610.00  #toplevel


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
activate_context :Test

LOOP_COUNT = 1000

require 'profile'

LOOP_COUNT.times {f.meth_proceed}
