require "spec_helper"

describe Phenomenal::Context do
  
  before :each do
    @context = Phenomenal::Context.new(:test)
    @context2 = Phenomenal::Context.new(:test2)
  end
  
  after :each  do
    force_forget_context(@context)
    force_forget_context(@context2)
  end
  
  it "should exist" do
     @context.should be_an_instance_of(Phenomenal::Context)
  end  
  
  it "should accept adaptations" do
    @context.should respond_to :add_adaptation
  end
  
  it "should accept removing of adaptations" do
    @context.should respond_to :remove_adaptation
  end
  
  describe "#name" do
    it "should have a name" do
      @context.should respond_to :name
    end
    
    it "should keep it's initial name" do
      @context.name.should == :test
    end
    
    it "should be anonymous if the name wasn't set" do
      Phenomenal::Context.new.name.should be_nil
    end
    
    it "should be anonymous if it is the default context" do
      Phenomenal::Manager.instance.default_context.name.should be_nil
    end
  end
  
  describe ".create" do
    pending "TODO"
  end
  
  describe "#forget" do
    pending "TODO"
  end
  
  describe "#add_adaptation" do
    pending "TODO"
  end
  describe "#context" do
    pending "TODO"
  end
  describe "#feature" do
    pending "TODO"
  end
  describe "#add_adaptations" do
    pending "TODO"
  end
  describe "#adapatations_for" do
    pending "TODO"
  end
  describe "#adapt" do
    pending "TODO"
  end
  describe "#adapt_klass" do
    pending "TODO"
  end
  describe "#remove_adaptation" do
    pending "TODO"
  end
  
  describe "(de)activation of contexts" do
    it "should initially not be active" do
      @context.active?.should be_false
    end
    
    describe "#activate" do
      it "should be activatable" do
        @context.should respond_to :activate
      end
      
      it "should activate the context" do
        @context.activate
        @context.active?.should be_true
      end
      
      it "should increment activation count" do
        @context.activate
        @context.activation_count.should == 1
        @context.activate
        @context.activation_count.should == 2
      end
      
      it "should reset activation age" do
       @context.activate
       @context.age.should == 0
       @context2.activate
      @context.age.should == 1
      end  
      
      it "should return the context on activation" do
        @context.should be @context.activate 
      end
    end
    
    describe "#deactivate" do
      it "should be deactivatable" do 
        @context.should respond_to :deactivate
      end
      
      it "should return the context on deactivation" do
        @context.should be @context.deactivate 
      end
      it "should be inactive after deactivation" do
        @context.activate
        @context.deactivate
        @context.active?.should be_false
      end
    end
    
    describe "Redundant (de)activations " do
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
    
    describe "#just_activated" do
      pending "TODO"
    end
  end
  
  describe "#anonymous" do
    pending "TODO"
  end
  
  describe "#information" do
    pending "TODO"
  end
  describe "#parent_feature" do
    it "should be the default feature parent for simple contexts" do
      c = context :b
      c.parent_feature.should be Phenomenal::Manager.instance.default_context
      c.forget
    end
    
    it "should be the closest feature for in-feature contexts" do
      c=nil
      f = feature :f do
        c=context :c do
        end
      end
      c.parent_feature.should be f
      c.forget
      f.forget
    end
  end
end

