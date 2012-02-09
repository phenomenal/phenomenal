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
end
