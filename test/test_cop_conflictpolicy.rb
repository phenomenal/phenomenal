require_relative "../lib/phenomenal.rb"
require_relative "./test_classes.rb"
require "test/unit"

class TestCopConflictPolicy < Test::Unit::TestCase
  def setup
    phen_define_context(:screening)
    phen_add_adaptation(:screening,Phone,:advertise) do |a_call|
      phen_proceed(a_call)+" with screening"
    end

    phen_define_context(:quiet)
    phen_add_adaptation(:quiet,Phone,:advertise){|a_call| "vibrator" }

  end

  def teardown
    while phen_context_active?(:screening) do
      phen_deactivate_context(:screening)
    end
    phen_forget_context(:screening)

    while phen_context_active?(:quiet) do
      phen_deactivate_context(:quiet)
    end
    phen_forget_context(:quiet)
    phen_change_conflict_policy { |a,b| no_resolution_conflict_policy(a,b) }
  end

  def test_no_resolution_policy
    assert_nothing_raised(Phenomenal::Error,"The first context have to be
      activated without any problem"){phen_activate_context(:screening)}
    assert_raise(Phenomenal::Error,"In the default policy, a second context
      that adapt the same method and is not the default one cannot
      be activated"){phen_activate_context(:quiet)}
  end

  def test_protocol_age_policy
    assert(phen_context_informations(
      phen_default_context)[:activation_age].kind_of?(Fixnum),
      "Contexts should have the age property")
  end

  def test_activation_age_policy
    phen_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    assert(phen_context_active?(phen_default_context), 
      "Default context should normally be active")
    assert(!phen_context_active?(:screening), "Context1 should be inactive")
    assert(!phen_context_active?(:quiet),"Context2 should be inactive")

    phen_activate_context(:screening)
    assert(phen_context_informations(:screening)[:activation_age] <
            phen_context_informations(phen_default_context)[:activation_age],
            "screening context has been activated more recently than default")

    phen_activate_context(:quiet)
    assert(phen_context_informations(:quiet)[:activation_age] <
            phen_context_informations(:screening)[:activation_age],
            "quiet context has been activated more recently than screening")
    assert(phen_context_informations(:screening)[:activation_age] <
            phen_context_informations(phen_default_context)[:activation_age],
            "quiet context has still been activated more recently than default")
    phen_deactivate_context(:quiet)
    phen_deactivate_context(:screening)
    phen_activate_context(:screening)
    assert(phen_context_informations(:screening)[:activation_age] <
            phen_context_informations(:quiet)[:activation_age],
            "screening context has now been activated more recently than quiet")
  end

  def test_conflicting_activation_age_policy
    phen_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    assert_nothing_raised(Phenomenal::Error,"The first context have to be
      activated without any problem"){phen_activate_context(:screening)}
    assert_nothing_raised(Phenomenal::Error,"In the age policy, a second context
      that adapt the same method and is not the default one should
      be activated without error"){phen_activate_context(:quiet)}
  end

  def test_interleaved_activation_age_policy
    phen_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    phone = Phone.new
    call = Call.new("Alice")
    phone.receive(call)

    assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed --> ringtone")

    phen_activate_context(:quiet)
    assert((phone.advertise(call))=="vibrator",
     "Call advertisement should adapt to quiet context")

    phen_activate_context(:screening)
    assert((phone.advertise(call))=="vibrator with screening",
     "Screening information should be overlaid over quiet context behaviour
      (vibrator)")

    phen_deactivate_context(:quiet)
    assert((phone.advertise(call))=="ringtone with screening",
     "Screening information should be overlaid over default context behaviour
      (ringtone)")

    phen_deactivate_context(:screening)
     assert((phone.advertise(call))=="ringtone",
     "Call advertisement should be reverted to the default")
  end

  def test_nested_activation_age_policy
    phen_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    phone = Phone.new
    call = Call.new("Alice")
    phone.receive(call)

    assert((phone.advertise(call))=="ringtone",
	    "Default behaviour should be expressed --> ringtone")

    phen_activate_context(:quiet)
    assert((phone.advertise(call))=="vibrator",
     "Call advertisement should adapt to quiet context")

    phen_activate_context(:screening)
    assert((phone.advertise(call))=="vibrator with screening",
     "Screening information should be overlaid over quiet context behaviour
      (vibrator)")

    phen_deactivate_context(:screening)
    assert((phone.advertise(call))=="vibrator",
     "Call advertisement should be reverted to that of quiet context")

    phen_deactivate_context(:quiet)
     assert((phone.advertise(call))=="ringtone",
     "Call advertisement should be reverted to the default")
  end

  def test_4_level_age_policy
    phen_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    phen_define_context(:level1)
    phen_add_adaptation(:level1,TestClass,:print) do |arg|
      phen_proceed(arg) + " 1 -> ARG1: #{arg.to_s}"
    end

    phen_define_context(:level2)
    phen_add_adaptation(:level2,TestClass,:print) do |arg|
      phen_proceed(arg) + " 2 -> ARG2: #{arg.to_s}"
    end

    phen_define_context(:level3)
    phen_add_adaptation(:level3,TestClass,:print) do |arg|
      phen_proceed(arg) + " 3 -> ARG3: #{arg.to_s}"
    end

    phen_define_context(:level4)
    phen_add_adaptation(:level4,TestClass,:print) do |arg|
      phen_proceed(arg) + " 4 -> ARG4: #{arg.to_s}"
    end
    t = TestClass.new("Foo")
    assert(t.print("bar")=="0 -> ARG: bar",
	    "Default behaviour should be expressed")
    phen_activate_context(:level1)
    phen_activate_context(:level2)
    phen_activate_context(:level3)
    phen_activate_context(:level4)
    assert(t.print("bar")==
    "0 -> ARG: bar 1 -> ARG1: bar 2 -> ARG2: bar 3 -> ARG3: bar 4 -> ARG4: bar",
	    "Composed behaviour should be expressed")
    phen_deactivate_context(:level1)
    phen_forget_context(:level1)
    phen_deactivate_context(:level2)
    phen_forget_context(:level2)
    phen_deactivate_context(:level3)
    phen_forget_context(:level3)
    phen_deactivate_context(:level4)
    phen_forget_context(:level4)
  end
end

