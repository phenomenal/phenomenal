require "spec_helper"

describe Phenomenal::Context do
  
  before :each do
    @context = Phenomenal::Context.new(:test)
  end
  
  after :each  do
    force_forget_context(@context)
  end
  
  describe "Basic protocol" do
    it "should exist" do
       @context.should be_an_instance_of(Phenomenal::Context)
    end  
    
    it "should be activatable" do
      @context.should respond_to :activate
    end
    
    it "should be deactivatable" do 
      @context.should respond_to :deactivate
    end
    
    it "should accept adaptations" do
      @context.should respond_to :add_adaptation
    end
    
    it "should accept removing of adaptations" do
      @context.should respond_to :remove_adaptation
    end
    
    it "should be possible to check activation state" do
      @context.should respond_to :active?
    end
    
    it "should have a name" do
      @context.should respond_to :name
    end
    
    it "should keep it's initial name" do
      @context.name.should == :test
    end
    
    it "should be anonymous if the name wasn't set" do
      Phenomenal::Context.new.name.should be_nil
    end
  end
  
  describe "(de)activation of contexts" do
    it "should initially not be active" do
      @context.active?.should be_false
    end
    
    it "should return the context on activation" do
      @context.should be @context.activate 
    end
    
    it "should be active after activation" do
      @context.activate
      @context.active?.should be_true
    end
    
    it "should return the context on deactivation" do
      @context.should be @context.deactivate 
    end
    
    it "should be inactive after deactivation" do
      @context.activate
      @context.deactivate
      @context.active?.should be_false
    end
    
    describe "Redundant (de)activations) " do
      before :each do
       10.times { @context.activate }
      end
      
      it "should stay active with fewer deactivations than activations" do
        9.times { @context.deactivate }
        @context.active?.should be true
      end
      
      it "should became inactive with same deactivations than activations" do
        10.times { @context.deactivate }
        @context.active?.should be false
      end
      
      it "should stay inactive with more deactivations than activations" do
        15.times { @context.deactivate }
        @context.active?.should be false
      end
      
      it "should not accumulate once the context is inactive" do 
        15.times { @context.deactivate }
        @context.activate
        @context.active?.should be true
      end
    end
  end
  
  describe "parent feature" do
    it "should be the default feature for basic contexts" do
      @context.parent_feature.should be Phenomenal::Manager.instance.default_context
    end
    
    it "should be the closest feature for in-feature contexts" do
      c =nil
      feature :f do
        c = context :a
      end
      c.parent_feature.should be feature(:f)
    end
  end
end

