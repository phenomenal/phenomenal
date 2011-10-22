require_relative "../lib/phenomenal.rb"
require_relative "./test_classes.rb"
require "test/unit"

class TestCopConflictPolicy < Test::Unit::TestCase
  def setup
    pnml_define_context(:screening)
    pnml_add_adaptation(:screening,Phone,:advertise) do |a_call|
      pnml_proceed(a_call)+" with screening"
    end

    pnml_define_context(:quiet)
    pnml_add_adaptation(:quiet,Phone,:advertise){|a_call| "vibrator" }

  end

  def teardown
    while pnml_context_active?(:screening) do
      pnml_deactivate_context(:screening)
    end
    pnml_forget_context(:screening)

    while pnml_context_active?(:quiet) do
      pnml_deactivate_context(:quiet)
    end
    pnml_forget_context(:quiet)
    pnml_change_conflict_policy { |a,b| no_resolution_conflict_policy(a,b) }
  end

  def test_no_resolution_policy
    assert_nothing_raised(Phenomenal::Error,"The first context have to be
      activated without any problem"){pnml_activate_context(:screening)}
    assert_raise(Phenomenal::Error,"In the default policy, a second context
      that adapt the same method and is not the default one cannot
      be activated"){pnml_activate_context(:quiet)}
  end

  def test_protocol_age_policy
    assert(pnml_context_informations(pnml_default_context)[:activation_age].kind_of?(Fixnum),
      "Contexts should have the age property")
  end

  def test_activation_age_policy
    pnml_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    puts "llll #{pnml_default_context.class}"
    assert(pnml_context_active?(pnml_default_context), 
      "Default context should normally be active")
    assert(!pnml_context_active?(:screening), "Context1 should be inactive")
    assert(!pnml_context_active?(:quiet),"Context2 should be inactive")

    pnml_activate_context(:screening)
    assert(pnml_context_informations(:screening)[:activation_age] <
            pnml_context_informations(pnml_default_context)[:activation_age],
            "screening context has been activated more recently than default")

    pnml_activate_context(:quiet)
    assert(pnml_context_informations(:quiet)[:activation_age] <
            pnml_context_informations(:screening)[:activation_age],
            "quiet context has been activated more recently than screening")
    assert(pnml_context_informations(:screening)[:activation_age] <
            pnml_context_informations(pnml_default_context)[:activation_age],
            "quiet context has still been activated more recently than default")
    pnml_deactivate_context(:quiet)
    pnml_deactivate_context(:screening)
    pnml_activate_context(:screening)
    assert(pnml_context_informations(:screening)[:activation_age] <
            pnml_context_informations(:quiet)[:activation_age],
            "screening context has now been activated more recently than quiet")
  end

  def test_conflicting_activation_age_policy
    pnml_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    assert_nothing_raised(Phenomenal::Error,"The first context have to be
      activated without any problem"){pnml_activate_context(:screening)}
    assert_nothing_raised(Phenomenal::Error,"In the age policy, a second context
      that adapt the same method and is not the default one should
      be activated without error"){pnml_activate_context(:quiet)}
  end

  def test_interleaved_activation_age_policy
    pnml_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    phone = Phone.new
    call = Call.new("Alice")
    phone.receive(call)

    assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed --> ringtone")

    pnml_activate_context(:quiet)
    assert((phone.advertise(call))=="vibrator",
     "Call advertisement should adapt to quiet context")

    pnml_activate_context(:screening)
    assert((phone.advertise(call))=="vibrator with screening",
     "Screening information should be overlaid over quiet context behaviour
      (vibrator)")

    pnml_deactivate_context(:quiet)
    assert((phone.advertise(call))=="ringtone with screening",
     "Screening information should be overlaid over default context behaviour
      (ringtone)")

    pnml_deactivate_context(:screening)
     assert((phone.advertise(call))=="ringtone",
     "Call advertisement should be reverted to the default")
  end

  def test_nested_activation_age_policy
    pnml_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    phone = Phone.new
    call = Call.new("Alice")
    phone.receive(call)

    assert((phone.advertise(call))=="ringtone",
	    "Default behaviour should be expressed --> ringtone")

    pnml_activate_context(:quiet)
    assert((phone.advertise(call))=="vibrator",
     "Call advertisement should adapt to quiet context")

    pnml_activate_context(:screening)
    assert((phone.advertise(call))=="vibrator with screening",
     "Screening information should be overlaid over quiet context behaviour
      (vibrator)")

    pnml_deactivate_context(:screening)
    assert((phone.advertise(call))=="vibrator",
     "Call advertisement should be reverted to that of quiet context")

    pnml_deactivate_context(:quiet)
     assert((phone.advertise(call))=="ringtone",
     "Call advertisement should be reverted to the default")
  end

  def test_4_level_age_policy
    pnml_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    pnml_define_context(:level1)
    pnml_add_adaptation(:level1,TestClass,:print) do |arg|
      pnml_proceed(arg) + " 1 -> ARG1: #{arg.to_s}"
    end

    pnml_define_context(:level2)
    pnml_add_adaptation(:level2,TestClass,:print) do |arg|
      pnml_proceed(arg) + " 2 -> ARG2: #{arg.to_s}"
    end

    pnml_define_context(:level3)
    pnml_add_adaptation(:level3,TestClass,:print) do |arg|
      pnml_proceed(arg) + " 3 -> ARG3: #{arg.to_s}"
    end

    pnml_define_context(:level4)
    pnml_add_adaptation(:level4,TestClass,:print) do |arg|
      pnml_proceed(arg) + " 4 -> ARG4: #{arg.to_s}"
    end
    t = TestClass.new("Foo")
    assert(t.print("bar")=="0 -> ARG: bar",
	    "Default behaviour should be expressed")
    pnml_activate_context(:level1)
    pnml_activate_context(:level2)
    pnml_activate_context(:level3)
    pnml_activate_context(:level4)
    assert(t.print("bar")==
    "0 -> ARG: bar 1 -> ARG1: bar 2 -> ARG2: bar 3 -> ARG3: bar 4 -> ARG4: bar",
	    "Composed behaviour should be expressed")
    pnml_deactivate_context(:level1)
    pnml_forget_context(:level1)
    pnml_deactivate_context(:level2)
    pnml_forget_context(:level2)
    pnml_deactivate_context(:level3)
    pnml_forget_context(:level3)
    pnml_deactivate_context(:level4)
    pnml_forget_context(:level4)
  end
end

