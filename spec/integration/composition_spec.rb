require "spec_helper"

describe "Composition of adaptations" do
  before :each do
    
    context(:screening) do
      adaptations_for Phone
      adapt :advertise do |a_call|
        proceed(a_call)+" with screening"
      end
    end
    
    context(:test)
  end
  
  after :each do
    force_forget_context(:screening)
    force_forget_context(:test)
  end
  
  it "should adapt methods without args" do
    prefix = "It's a nice "
    suffix = "simple composition"
    composed = prefix+suffix
    inst = TestClass.new(prefix)
    phen_add_adaptation(:test,String,:to_s) {phen_proceed+suffix}
    
    inst.to_s.should == prefix
    activate_context(:test)
    inst.to_s.should==composed
  end
  
  it "should adapt methods with args" do
    str="Nice String!"
    inst= TestClass.new(str)
    phen_add_adaptation(:test,String,:eql?) do | str |
      if phen_proceed(str)
        "OK"
      else
        "KO"
      end
    end
    
    inst.eql?(str).should be_true
    activate_context(:test)
    
    inst.eql?(str).should=="OK"
    inst.eql?(str+str).should=="KO"
  end
  
  it "should allow nested compositions" do
    phone = Phone.new
    call = Call.new("Alice")
    phone.receive(call)

    phone.advertise(call).should=="ringtone"
    activate_context(:screening)
    phone.advertise(call).should=="ringtone with screening"
    deactivate_context(:screening)
    phone.advertise(call).should=="ringtone"
  end
end
