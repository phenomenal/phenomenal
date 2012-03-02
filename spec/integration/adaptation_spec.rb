require "spec_helper"

describe "Simple adaptations" do
  before :each do
  
    phen_change_conflict_policy { |a,b| no_resolution_conflict_policy(a,b) }
    
    context(:quiet) do
      adaptations_for Phone
      adapt :advertise do |a_call|
        "vibrator"
      end 
    end
    
    context(:offHook) do
      adaptations_for Phone
      adapt :advertise do |a_call|
        "call waiting signal"
      end 
    end

    
    context(:test) do
      adaptations_for TestClass
      adapt :to_s do
        @value + " @access " + value + " attr_accessor_access"
      end
    end
    
    context(:test_2) do
      adaptations_for TestClass
      adapt_class :klass_var_access do
        @@klass_var+1
      end
    end

    context(:test_3) do
      adaptations_for TestClass
      adapt_class :klass_inst_var_access do
        @klass_inst_var+1
      end
    end
    
  end
  
  after :each do
    force_forget_context(context(:quiet))
    force_forget_context(context(:offHook))
    force_forget_context(context(:test))
    force_forget_context(context(:test_2))
    force_forget_context(context(:test_3))
    
    phen_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
  end
  
  it "should override default behavior" do
    phone = Phone.new
    call = Call.new("Bob")
  	phone.receive(call)
  	phone.advertise(call).should=="ringtone"
  	activate_context(:quiet)
  	phone.advertise(call).should=="vibrator"
  	deactivate_context(:quiet)
  	phone.advertise(call).should=="ringtone"
  end
  
  it "should refuse confliction adaptations in the same context" do
    expect{context(:quiet).add_adaptation(Phone,:advertise,true) do |a_call|
        "A call test"
      end}.to raise_error Phenomenal::Error
  end
  
  it "should refuse adaptations for inexistent methods" do
    expect{phen_add_adaptation(:test,Phone,:phonyAdvertise){|a_call| "vibrator"}}.
    to raise_error Phenomenal::Error
  end
  
  it "should be possible to add/remove adaptations at runtime" do
    phone = Phone.new
    call = Call.new("Bob")
  	phone.receive(call)
  	
  	activate_context(:quiet)
    phen_context_active?(:quiet).should be_true
    expect{phen_remove_adaptation(:quiet,Phone,:advertise)}.to_not raise_error
    
    phone.advertise(call).should=="ringtone"
    
    expect{phen_add_adaptation(:quiet,Phone,:advertise){|a_call| "vibrator" }}.to_not raise_error
    
    phone.advertise(call).should=="vibrator"
    expect{deactivate_context(:quiet)}.to_not raise_error
    
    phone.advertise(call).should=="ringtone"
  end
  
  it "should be possible to access instance variables in adaptations" do
    t = TestClass.new("VAR")
    t.to_s.should=="VAR"
    
    activate_context(:test)
    
    t.to_s.should == "VAR @access VAR attr_accessor_access"

    deactivate_context(:test)
    t.to_s.should=="VAR"
  end
  
  it "sould be possible to access class variables" do
    TestClass.klass_var_access.should==1
    activate_context(:test_2)
    
    pending "Adaptations doesn't have access to class variables, seems to be a Ruby bug"
    TestClass.klass_var_access.should==2
    
    deactivate_context(:test_2)
    TestClass.klass_var_access.should==1
  end
  
  it "should be possible to access class instance variables adaptations" do
    TestClass.klass_inst_var_access.should==2
    
    activate_context(:test_3)
    TestClass.klass_inst_var_access.should==3

    deactivate_context(:test_3)
    TestClass.klass_inst_var_access.should==2
  end
end
