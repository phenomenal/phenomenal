require_relative "../lib/phenomenal.rb"
require_relative "./test_classes.rb"
require "test/unit"

class TestCopComposition < Test::Unit::TestCase
  def setup
    phen_context(:screening)
    phen_add_adaptation(:screening,Phone,:advertise) do |a_call|
      phen_proceed(a_call)+" with screening"
    end
    phen_context(:test)
  end

  def teardown
    while phen_context_active?(:test) do
      phen_deactivate_context(:test)
    end
    phen_forget_context(:test)

    while phen_context_active?(:screening) do
      phen_deactivate_context(:screening)
    end
    phen_forget_context(:screening)
  end

  def test_invalid_proceed
    assert_raise(Phenomenal::Error, %( 
      Proceed cannot be used outside adaptation of
     other methods)) {phen_proceed}
  end

  def test_simple_composition_noargs
    prefix = "It's a nice "
    suffix = "simple composition"
    composed = prefix+suffix
    inst = TestClass.new(prefix)
    phen_add_adaptation(:test,String,:to_s) {phen_proceed+suffix}
    assert(inst.to_s==prefix,
      "The base to_s method of String must have its default behaviour")
    phen_activate_context(:test)
    assert(inst.to_s==composed,
      %(The adapted to_s method of String must had '#{suffix}'
         at the end of the string))
  end

  def test_simple_composition_args
    str="Nice String!"
    inst= TestClass.new(str)
    phen_add_adaptation(:test,String,:eql?) do | str |
      if phen_proceed(str)
        "OK"
      else
        "KO"
      end
    end
    assert(inst.eql?(str),
      "The base eql? method of String must have its default behaviour")
    phen_activate_context(:test)
    assert(inst.eql?(str)=="OK",
      %(The adapted eql? method of String must return 'OK' if the two string
        are equal))
    assert(inst.eql?(str+str)=="KO",
      %(The adapted eql? method of String must return 'KO' if the two string
        are not equal))
  end

  def test_nested_activation
    phone = Phone.new
    call = Call.new("Alice")
    phone.receive(call)

    assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed")
  	 phen_activate_context(:screening)
  	 assert((phone.advertise(call))=="ringtone with screening",
  	  %(Screening information should be overlaid over the default ringtone
  	  advertisement'.))
  	  phen_deactivate_context(:screening)
  	 assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed")

  end
end

