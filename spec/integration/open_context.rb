require "spec_helper"

describe "Open context facilities" do
  before :each do
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
  end
  
  after :each do
    force_forget_context(:screening)
    force_forget_context(:test)
  end
  
  it "should be possible to open an existent context and add adaptations in it" do
    phone = Phone.new
    call = Call.new("Bob")
  	phone.receive(call)
  	
  	activate_context(:quiet)
    phen_context_active?(:quiet).should be_true
    context :quiet do
      remove_adaptation(Phone,:advertise,true)
    end
    
    phone.advertise(call).should=="ringtone"
    
    context :quiet do
      adaptations_for Phone
      adapt :advertise {|a_call| "vibrator" }
    end

    phone.advertise(call).should=="vibrator"
    deactivate_context(:quiet)
    
    phone.advertise(call).should=="ringtone"
  end
end
