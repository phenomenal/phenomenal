require_relative "../lib/phenomenal.rb"
require "test/unit"

class TestCopConflictPolicy < Test::Unit::TestCase
  def setup
    ctxt_def(:screening)
    ctxt_add_adaptation(:screening,Phone,:advertise) do |a_call|
      ctxt_proceed(a_call)+" with screening"
    end

    ctxt_def(:quiet)
    ctxt_add_adaptation(:quiet,Phone,:advertise){|a_call| "vibrator" }

  end

  def teardown
    while ctxt_active?(:screening) do
      ctxt_deactivate(:screening)
    end
    ctxt_forget(:screening)

    while ctxt_active?(:quiet) do
      ctxt_deactivate(:quiet)
    end
    ctxt_forget(:quiet)
    ctxt_change_policy { |a,b| no_resolution_conflict_policy(a,b) }
  end

  def test_no_resolution_policy
    assert_nothing_raised(ContextError,"The first context have to be
      activated without any problem"){ctxt_activate(:screening)}
    assert_raise(ContextError,"In the default policy, a second context
      that adapt the same method and is not the default one cannot
      be activated"){ctxt_activate(:quiet)}
  end

  def test_protocol_age_policy
    assert(ctxt_informations(:default)[:activation_age].kind_of?(Fixnum),
      "Contexts should have the age property")
  end

  def test_activation_age_policy
    ctxt_change_policy { |a,b| age_conflict_policy(a,b) }
    assert(ctxt_active?(:default), "Default context should normally be active")
    assert(!ctxt_active?(:screening), "Context1 should be inactive")
    assert(!ctxt_active?(:quiet),"Context2 should be inactive")

    ctxt_activate(:screening)
    assert(ctxt_informations(:screening)[:activation_age] <
            ctxt_informations(:default)[:activation_age],
            "screening context has been activated more recently than default")

    ctxt_activate(:quiet)
    assert(ctxt_informations(:quiet)[:activation_age] <
            ctxt_informations(:screening)[:activation_age],
            "quiet context has been activated more recently than screening")
    assert(ctxt_informations(:screening)[:activation_age] <
            ctxt_informations(:default)[:activation_age],
            "quiet context has still been activated more recently than default")
    ctxt_deactivate(:quiet)
    ctxt_deactivate(:screening)
    ctxt_activate(:screening)
    assert(ctxt_informations(:screening)[:activation_age] <
            ctxt_informations(:quiet)[:activation_age],
            "screening context has now been activated more recently than quiet")
  end

  def test_conflicting_activation_age_policy
    ctxt_change_policy { |a,b| age_conflict_policy(a,b) }
    assert_nothing_raised(ContextError,"The first context have to be
      activated without any problem"){ctxt_activate(:screening)}
    assert_nothing_raised(ContextError,"In the age policy, a second context
      that adapt the same method and is not the default one should
      be activated without error"){ctxt_activate(:quiet)}
  end

  def test_interleaved_activation_age_policy
    ctxt_change_policy { |a,b| age_conflict_policy(a,b) }
    phone = Phone.new
    call = Call.new("Alice")
    phone.receive(call)

    assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed --> ringtone")

    ctxt_activate(:quiet)
    assert((phone.advertise(call))=="vibrator",
     "Call advertisement should adapt to quiet context")

    ctxt_activate(:screening)
    assert((phone.advertise(call))=="vibrator with screening",
     "Screening information should be overlaid over quiet context behaviour
      (vibrator)")

    ctxt_deactivate(:quiet)
    assert((phone.advertise(call))=="ringtone with screening",
     "Screening information should be overlaid over default context behaviour
      (ringtone)")

    ctxt_deactivate(:screening)
     assert((phone.advertise(call))=="ringtone",
     "Call advertisement should be reverted to the default")
  end

  def test_nested_activation_age_policy
    ctxt_change_policy { |a,b| age_conflict_policy(a,b) }
    phone = Phone.new
    call = Call.new("Alice")
    phone.receive(call)

    assert((phone.advertise(call))=="ringtone",
	    "Default behaviour should be expressed --> ringtone")

    ctxt_activate(:quiet)
    assert((phone.advertise(call))=="vibrator",
     "Call advertisement should adapt to quiet context")

    ctxt_activate(:screening)
    assert((phone.advertise(call))=="vibrator with screening",
     "Screening information should be overlaid over quiet context behaviour
      (vibrator)")

    ctxt_deactivate(:screening)
    assert((phone.advertise(call))=="vibrator",
     "Call advertisement should be reverted to that of quiet context")

    ctxt_deactivate(:quiet)
     assert((phone.advertise(call))=="ringtone",
     "Call advertisement should be reverted to the default")
  end

  def test_4_level_age_policy
    ctxt_change_policy { |a,b| age_conflict_policy(a,b) }
    ctxt_def(:level1)
    ctxt_add_adaptation(:level1,TestClass,:print) do |arg|
      ctxt_proceed(arg) + " 1 -> ARG1: #{arg.to_s}"
    end

    ctxt_def(:level2)
    ctxt_add_adaptation(:level2,TestClass,:print) do |arg|
      ctxt_proceed(arg) + " 2 -> ARG2: #{arg.to_s}"
    end

    ctxt_def(:level3)
    ctxt_add_adaptation(:level3,TestClass,:print) do |arg|
      ctxt_proceed(arg) + " 3 -> ARG3: #{arg.to_s}"
    end

    ctxt_def(:level4)
    ctxt_add_adaptation(:level4,TestClass,:print) do |arg|
      ctxt_proceed(arg) + " 4 -> ARG4: #{arg.to_s}"
    end
    t = TestClass.new("Foo")
    assert(t.print("bar")=="0 -> ARG: bar",
	    "Default behaviour should be expressed")
    ctxt_activate(:level1)
    ctxt_activate(:level2)
    ctxt_activate(:level3)
    ctxt_activate(:level4)
    assert(t.print("bar")==
    "0 -> ARG: bar 1 -> ARG1: bar 2 -> ARG2: bar 3 -> ARG3: bar 4 -> ARG4: bar",
	    "Composed behaviour should be expressed")
    ctxt_deactivate(:level1)
    ctxt_forget(:level1)
    ctxt_deactivate(:level2)
    ctxt_forget(:level2)
    ctxt_deactivate(:level3)
    ctxt_forget(:level3)
    ctxt_deactivate(:level4)
    ctxt_forget(:level4)
  end
end

