require "spec_helper"

describe "Combined contexts" do
  it "should be possible to define combined contexts" do
    expect{ context :a,:b}.to_not raise_error
    force_forget_context(:a)
    force_forget_context(:b)
  end
  
  it "should reopen the same combined context " do
    context(:a,:b).should==context(:a,:b)
    force_forget_context(:a)
    force_forget_context(:b)
  end
  
  it "should use the adaptation of the combined context before the adaptations of the separated contexts" do
    context :a do
      adaptations_for TestString2
      adapt :length do 
        84
      end
    end
    
    context :a,:b do
      adaptations_for TestString2
      adapt :length do 
        42
      end
    end
    
    
    inst = TestString2.new("1234")
    inst.length.should==4
    activate_context :a
    inst.length.should==84
    activate_context :b
    inst.length.should==42
    activate_context :a
    inst.length.should==42
    deactivate_context :a
    deactivate_context :a
    inst.length.should==4
    
    force_forget_context(:a)
    force_forget_context(:b)
  end
  
end
