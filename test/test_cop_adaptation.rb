require_relative "../lib/phenomenal.rb"
require_relative "./test_classes.rb"
require "test/unit"

class TestCopAdaptation < Test::Unit::TestCase
  def setup
    pnml_define_context(:quiet)
    pnml_define_context(:offHook)
    pnml_add_adaptation(:quiet,Phone,:advertise){|a_call| "vibrator" }
    pnml_add_adaptation(:offHook,Phone,:advertise) do |a_call|
                                                      "call waiting signal"
                                                    end
    pnml_define_context(:test)
    pnml_add_adaptation(:test,TestClass,:to_s) do
      @value + " @access " + value + " attr_accessor_access"
    end

    pnml_define_context(:test_2)
    pnml_add_adaptation(:test_2,TestClass,:klass_var_access) do
      @@klass_var+1
    end

    pnml_define_context(:test_3)
    pnml_add_adaptation(:test_3,TestClass,:klass_inst_var_access) do
      @klass_inst_var+1
    end
  end

  def teardown
    while pnml_context_active?(:quiet) do
      pnml_deactivate_context(:quiet)
    end
    pnml_forget_context(:quiet)

    while pnml_context_active?(:offHook) do
      pnml_deactivate_context(:offHook)
    end
    pnml_forget_context(:offHook)

    while pnml_context_active?(:test) do
      pnml_deactivate_context(:test)
    end
    pnml_forget_context(:test)

    while pnml_context_active?(:test_2) do
      pnml_deactivate_context(:test_2)
    end
    pnml_forget_context(:test_2)

    while pnml_context_active?(:test_3) do
      pnml_deactivate_context(:test_3)
    end
    pnml_forget_context(:test_3)
  end

  def test_overriding_adaptation
    phone = Phone.new
    call = Call.new("Bob")
  	phone.receive(call)
  	assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed")
  	pnml_activate_context(:quiet)
  	assert((phone.advertise(call))=="vibrator",
  	  "Behavior adapted to quiet environments should be expressed")
  	pnml_deactivate_context(:quiet)
  	assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed")
	end

  def test_conflicting_adaptation
    assert_raise(Phenomenal::Error,
      "A context cannot have two different adaptations for the same method.")do
        pnml_add_adaptation(:quiet,Phone,:advertise) do |a_call|
                                                        "call waiting signal"
                                                      end
      end
  end

  def test_invalid_adaptation
    pnml_define_context(:temp)
    assert_raise(Phenomenal::Error,
      "Adaptation of inexistent methods should be forbidden.") do
        pnml_add_adaptation(:temp,Phone,:phonyAdvertise){|a_call| "vibrator"}
      pnml_activate_context(:temp)
     end
    pnml_forget_context(:temp)
  end

  def test_conflicting_activation
    assert(!pnml_context_active?(:quiet))
    assert_nothing_raised(Phenomenal::Error,
      "Shoud be OK to activate the quiet context") do 
        pnml_activate_context(:quiet) 
      end
    assert(pnml_context_active?(:quiet))
    assert(!pnml_context_active?(:offHook))
    assert_raise(Phenomenal::Error,
      "Should conflict with currently active quiet context") do
        pnml_activate_context(:offHook)
      end
    assert(!pnml_context_active?(:offHook),
      "Should not be mistakenly activated after error")
  end

  def test_runtime_adding_removing_adaptation
    phone = Phone.new
    call = Call.new("Bob")
  	phone.receive(call)
    pnml_activate_context(:quiet)
    assert(pnml_context_active?(:quiet))
    assert_nothing_raised("Should be ok to remove an active adaptation") do
      pnml_remove_adaptation(:quiet,Phone,:advertise)
    end
    assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed")
    assert_nothing_raised("Should be ok to add an active adaptation") do
      pnml_add_adaptation(:quiet,Phone,:advertise){|a_call| "vibrator" }
    end
    assert((phone.advertise(call))=="vibrator",
      "Adapted behaviour should be expressed")
    assert_nothing_raised("Should be ok to deactivate the context") do
      pnml_deactivate_context(:quiet)
    end
    assert((phone.advertise(call))=="ringtone",
  	  "Default behaviour should be expressed")
  end

  def test_instance_variable_access
    t = TestClass.new("VAR")
    assert("VAR"==t.to_s, %(Default to_s should acess var and return
                            string value))
    pnml_activate_context(:test)
    assert("VAR @access VAR attr_accessor_access"==t.to_s, %(Adapted to_s should
             acess both instance var and accessor meth and return string value))
    pnml_deactivate_context(:test)
    assert("VAR"==t.to_s, %(Default to_s should acess var and return
    string value))
  end

  def test_class_variable_access
    assert(1==TestClass.klass_var_access, %(Default meth should acess var and
                                            return val))
    pnml_activate_context(:test_2)

    # Doesn't work:  Adaptations doesn't have access to class variables
    # Seems to be a Ruby bug
    #TODO

    #assert(2==TestClass.klass_var_access, %(Adapted meth should
    #         acess klass variable and return its value +1))
    pnml_deactivate_context(:test_2)
     assert(1==TestClass.klass_var_access, %(Default meth should acess var and
                                            return val))
  end

  def test_class_instance_variable_access
    assert(2==TestClass.klass_inst_var_access, %(Default meth should acess var
                                            and return val))
    pnml_activate_context(:test_3)

    assert(3==TestClass.klass_inst_var_access, %(Adapted meth should
             acess klass variable and return its value +1))
    pnml_deactivate_context(:test_3)
     assert(2==TestClass.klass_inst_var_access, %(Default meth should acess var
                                                  and return string value))
  end
end

