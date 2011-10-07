require_relative "../lib/phenomenal.rb"
require "test/unit"

class TestCopComposition < Test::Unit::TestCase
  def setup
    ctxt_def(:screening)
    ctxt_add_adaptation(:screening,Phone,:advertise) do |a_call|
      ctxt_proceed(a_call)+" with screening"
    end
    ctxt_def(:test)
  end

  def teardown
    while ctxt_active?(:test) do
      ctxt_deactivate(:test)
    end
    ctxt_forget(:test)

    while ctxt_active?(:screening) do
      ctxt_deactivate(:screening)
    end
    ctxt_forget(:screening)
  end

  def test_invalid_proceed
    assert_raise(ContextError, %( Proceed cannot be used outside adaptation of
                                  other methods)) {ctxt_proceed}
  end

  def test_simple_composition_noargs
    prefix = "It's a nice "
    suffix = "simple composition"
    composed = prefix+suffix
    inst = TestClass.new(prefix)
    ctxt_add_adaptation(:test,String,:to_s) {ctxt_proceed+suffix}
    assert(inst.to_s==prefix,
      "The base to_s method of String must have its default behaviour")
    ctxt_activate(:test)
    assert(inst.to_s==composed,
      %(The adapted to_s method of String must had '#{suffix}'
         at the end of the string))
  end

  def test_simple_composition_args
    str="Nice String!"
    inst= TestClass.new(str)
    ctxt_add_adaptation(:test,String,:eql?) do | str |
      if ctxt_proceed(str)
        "OK"
      else
        "KO"
      end
    end
    assert(inst.eql?(str),
      "The base eql? method of String must have its default behaviour")
    ctxt_activate(:test)
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
  	 ctxt_activate(:screening)
  	 assert((phone.advertise(call))=="ringtone with screening",
  	  %(Screening information should be overlaid over the default ringtone
  	  advertisement'.))
  	  ctxt_deactivate(:screening)
  	 assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed")

  end
end

