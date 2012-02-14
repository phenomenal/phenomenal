require "spec_helper"

describe "Conflict policies" do
  phen_change_conflict_policy { |a,b| no_resolution_conflict_policy(a,b) }
  before :each do
    context(:screening) do
      adaptations_for Phone
      adapt :advertise do |a_call|
        phen_proceed(a_call)+" with screening"
      end
    end
    
    context(:quiet) do  
      adaptations_for Phone
      adapt :advertise do |a_call| 
        "vibrator" 
      end
    end    
  end
  
  after :each do
    force_forget_context(:screening)
    force_forget_context(:quiet)
    phen_change_conflict_policy { |a,b| no_resolution_conflict_policy(a,b) }
  end
  
  it "should not allow two contexts with an adaptation for the same method to be active at the same time" do
  
  expect{activate_context(:screening)}.to_not raise_error
  expect{activate_context(:quiet)}.to raise_error Phenomenal::Error  
  end
  
  it "should set the age of the context such that the most recent one has the smaller age" do
    phen_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    
    phen_context_active?(phen_default_context).should be_true
    phen_context_active?(:screening).should be_false
    phen_context_active?(:quiet).should be_false

    phen_activate_context(:screening)
    
    (phen_context_information(:screening)[:age] <
            phen_context_information(phen_default_context)[:age]).should be_true,
            "screening context has been activated more recently than default"

    phen_activate_context(:quiet)
    (phen_context_information(:quiet)[:age] <
            phen_context_information(:screening)[:age]).should be_true
            "quiet context has been activated more recently than screening"
    (phen_context_information(:screening)[:age] <
            phen_context_information(phen_default_context)[:age]).should be_true,
            "quiet context has still been activated more recently than default"
    phen_deactivate_context(:quiet)
    phen_deactivate_context(:screening)
    phen_activate_context(:screening)
    (phen_context_information(:screening)[:age] <
          phen_context_information(:quiet)[:age]).should be_true,
            "screening context has now been activated more recently than quiet"
  end
  
  it "should choose the context the most recently activated" do
    phen_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    expect{activate_context(:screening)}.to_not raise_error
    expect{activate_context(:quiet)}.to_not raise_error
  end
  
  it "should work with interleaved activation of contexts" do
    phen_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    phone = Phone.new
    call = Call.new("Alice")
    phone.receive(call)

    phone.advertise(call).should=="ringtone"

    activate_context(:quiet)
    phone.advertise(call).should=="vibrator"

    activate_context(:screening)
    phone.advertise(call).should=="vibrator with screening"

    deactivate_context(:quiet)
    phone.advertise(call).should=="ringtone with screening"

    deactivate_context(:screening)
    phone.advertise(call).should=="ringtone"
  end
  
  it "should nest calls with the age policy" do
    phen_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    phone = Phone.new
    call = Call.new("Alice")
    phone.receive(call)

    phone.advertise(call).should=="ringtone"

    activate_context(:quiet)
    phone.advertise(call).should=="vibrator"

    activate_context(:screening)
    phone.advertise(call).should=="vibrator with screening"

    deactivate_context(:screening)
    phone.advertise(call).should=="vibrator"

    deactivate_context(:quiet)
    phone.advertise(call).should=="ringtone"
  end
  
  it "should PPPPPPPPPPPPPPPPPPPP" do
    phen_change_conflict_policy { |a,b| age_conflict_policy(a,b) }
    context(:level1)
    phen_add_adaptation(:level1,TestClass,:print) do |arg|
      phen_proceed(arg) + " 1 -> ARG1: #{arg.to_s}"
    end

    context(:level2)
    phen_add_adaptation(:level2,TestClass,:print) do |arg|
      phen_proceed(arg) + " 2 -> ARG2: #{arg.to_s}"
    end

    context(:level3)
    phen_add_adaptation(:level3,TestClass,:print) do |arg|
      phen_proceed(arg) + " 3 -> ARG3: #{arg.to_s}"
    end

    context(:level4)
    phen_add_adaptation(:level4,TestClass,:print) do |arg|
      phen_proceed(arg) + " 4 -> ARG4: #{arg.to_s}"
    end
    t = TestClass.new("Foo")
    t.print("bar").should=="0 -> ARG: bar"
    activate_context(:level1)
    activate_context(:level2)
    activate_context(:level3)
    activate_context(:level4)
    t.print("bar").should=="0 -> ARG: bar 1 -> ARG1: bar 2 -> ARG2: bar 3 -> ARG3: bar 4 -> ARG4: bar"
    force_forget_context(:level1)
    force_forget_context(:level2)
    force_forget_context(:level3)
    force_forget_context(:level4)
  end
end
