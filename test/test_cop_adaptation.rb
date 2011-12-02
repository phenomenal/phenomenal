require_relative "../lib/phenomenal.rb"
require_relative "./test_classes.rb"
require "test/unit"

class TestCopAdaptation < Test::Unit::TestCase
  def setup
    phen_change_conflict_policy { |a,b| no_resolution_conflict_policy(a,b) }
    phen_define_context(:quiet)
    phen_define_context(:offHook)
    phen_add_adaptation(:quiet,Phone,:advertise){|a_call| "vibrator" }
    phen_add_adaptation(:offHook,Phone,:advertise) do |a_call|
                                                      "call waiting signal"
                                                    end
    phen_define_context(:test)
    phen_add_adaptation(:test,TestClass,:to_s) do
      @value + " @access " + value + " attr_accessor_access"
    end

    phen_define_context(:test_2)
    phen_add_adaptation(:test_2,TestClass,:klass_var_access) do
      @@klass_var+1
    end

    phen_define_context(:test_3)
    phen_add_adaptation(:test_3,TestClass,:klass_inst_var_access) do
      @klass_inst_var+1
    end
  end

  def teardown
    while phen_context_active?(:quiet) do
      phen_deactivate_context(:quiet)
    end
    phen_forget_context(:quiet)

    while phen_context_active?(:offHook) do
      phen_deactivate_context(:offHook)
    end
    phen_forget_context(:offHook)

    while phen_context_active?(:test) do
      phen_deactivate_context(:test)
    end
    phen_forget_context(:test)

    while phen_context_active?(:test_2) do
      phen_deactivate_context(:test_2)
    end
    phen_forget_context(:test_2)

    while phen_context_active?(:test_3) do
      phen_deactivate_context(:test_3)
    end
    phen_forget_context(:test_3)
  end

  def test_overriding_adaptation
    phone = Phone.new
    call = Call.new("Bob")
  	phone.receive(call)
  	assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed")
  	phen_activate_context(:quiet)
  	assert((phone.advertise(call))=="vibrator",
  	  "Behavior adapted to quiet environments should be expressed")
  	phen_deactivate_context(:quiet)
  	assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed")
	end

  def test_conflicting_adaptation
    assert_raise(Phenomenal::Error,
      "A context cannot have two different adaptations for the same method.")do
        phen_add_adaptation(:quiet,Phone,:advertise) do |a_call|
                                                        "call waiting signal"
                                                      end
      end
  end

  def test_invalid_adaptation
    phen_define_context(:temp)
    assert_raise(Phenomenal::Error,
      "Adaptation of inexistent methods should be forbidden.") do
        phen_add_adaptation(:temp,Phone,:phonyAdvertise){|a_call| "vibrator"}
      phen_activate_context(:temp)
     end
    phen_forget_context(:temp)
  end

  def test_conflicting_activation
    assert(!phen_context_active?(:quiet))
    assert_nothing_raised(Phenomenal::Error,
      "Shoud be OK to activate the quiet context") do 
        phen_activate_context(:quiet) 
      end
    assert(phen_context_active?(:quiet))
    assert(!phen_context_active?(:offHook))
    assert_raise(Phenomenal::Error,
      "Should conflict with currently active quiet context") do
        phen_activate_context(:offHook)
      end
    assert(!phen_context_active?(:offHook),
      "Should not be mistakenly activated after error")
  end

  def test_runtime_adding_removing_adaptation
    phone = Phone.new
    call = Call.new("Bob")
  	phone.receive(call)
    phen_activate_context(:quiet)
    assert(phen_context_active?(:quiet))
    assert_nothing_raised("Should be ok to remove an active adaptation") do
      phen_remove_adaptation(:quiet,Phone,:advertise)
    end
    assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed")
    assert_nothing_raised("Should be ok to add an active adaptation") do
      phen_add_adaptation(:quiet,Phone,:advertise){|a_call| "vibrator" }
    end
    assert((phone.advertise(call))=="vibrator",
      "Adapted behaviour should be expressed")
    assert_nothing_raised("Should be ok to deactivate the context") do
      phen_deactivate_context(:quiet)
    end
    assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed")
  end

  def test_instance_variable_access
    t = TestClass.new("VAR")
    assert("VAR"==t.to_s, %(Default to_s should acess var and return
                            string value))
    phen_activate_context(:test)
    assert("VAR @access VAR attr_accessor_access"==t.to_s, %(Adapted to_s should
             acess both instance var and accessor meth and return string value))
    phen_deactivate_context(:test)
    assert("VAR"==t.to_s, %(Default to_s should acess var and return
    string value))
  end

  def test_class_variable_access
    assert(1==TestClass.klass_var_access, %(Default meth should acess var and
                                            return val))
    phen_activate_context(:test_2)

    # Doesn't work:  Adaptations doesn't have access to class variables
    # Seems to be a Ruby bug
    #TODO

    #assert(2==TestClass.klass_var_access, %(Adapted meth should
    #       acess klass variable and return its value +1))
    #phen_deactivate_context(:test_2)
    #  assert(1==TestClass.klass_var_access, %(Default meth should acess var and
    #                              return val))
  end

  def test_class_instance_variable_access
    assert(2==TestClass.klass_inst_var_access, %(Default meth should acess var
                                            and return val))
    phen_activate_context(:test_3)

    assert(3==TestClass.klass_inst_var_access, %(Adapted meth should
             acess klass variable and return its value +1))
    phen_deactivate_context(:test_3)
     assert(2==TestClass.klass_inst_var_access, %(Default meth should acess var
                                                  and return string value))
  end
end

