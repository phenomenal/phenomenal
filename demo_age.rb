require_relative "./lib/phenomenal.rb"

pnml_change_conflict_policy { |a,b| age_conflict_policy(a,b) }

class Plop
  @@klass_var  = "PPPP"
  @klass_inst_var = "xD"
  attr_accessor :test

  def initialize
    @test = ">BOR<"
  end

  def print(arg)
    "0 -> Test: #{self.test} default Plop.print(arg): ARG: #{arg.to_s}"
  end

  def self.plop(arg)
    "SELF 0 #{arg} KlassVar: #{@@klass_var} INSTKLS #{@klass_inst_var}"
  end
end

pnml_define_context(:level1)

pnml_add_adaptation(:level1,Plop,:print) do |arg|
  pnml_proceed(arg) + "\n" + "1 -> level1 ARG1: #{arg.to_s}"
end

pnml_add_adaptation(:level1,Plop,:plop) do |arg|
  pnml_proceed(arg) + "\n" + "1 -> SELF level1 ARG1: #{arg.to_s} INSTKLS #{@kls_var}"
end

pnml_define_context(:level2)

pnml_add_adaptation(:level2,Plop,:print) do |arg|
  pnml_proceed(arg) + "\n" + "2 -> level2 ARG2: #{arg.to_s}"
end

pnml_add_adaptation(:level2,Plop,:plop) do |arg|
  pnml_proceed(arg) + "\n" + "2 -> SELF level2 ARG2: #{arg.to_s} INSTKLS #{@kls_inst_var}"
end

pnml_define_context(:level3)

pnml_add_adaptation(:level3,Plop,:print) do |arg|
  pnml_proceed(arg) + "\n" + "3 -> level3 ARG3: #{arg.to_s}"
end

pnml_define_context(:level4)

pnml_add_adaptation(:level4,Plop,:print) do |arg|
  pnml_proceed(arg) + "\n" + "4 -> TEST4: #{@test} level4 ARG4: #{arg.to_s}"
end

p = Plop.new

puts "=============> LEVEL 0 <===============\n"+
p.print("foo")+
"\n======================================="

pnml_activate_context(:level1)
puts "=============> LEVEL 1 <===============\n"+
p.print("foo1")+
"\n======================================="

pnml_activate_context(:level2)
puts "=============> LEVEL 2 <===============\n"+
p.print("foo2")+
"\n======================================="

pnml_activate_context(:level3)
puts "=============> LEVEL 3 <===============\n"+
p.print("foo3")+
"\n======================================="
p.test=">BAR<"
pnml_activate_context(:level4)
puts "=============> LEVEL 4 <===============\n"+
p.print("foo4")+
"\n======================================="

pnml_deactivate_context(:level3)
puts "=============> LEVEL 4 -3 <===============\n"+
p.print("foo4-2")+
"\n======================================="

puts "\n\n========> LEVEL 4 -3 KLASS METH<===========\n"+
 Plop.plop(">KLASS_METH_ARG<") +
"\n======================================="

