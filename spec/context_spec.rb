require "spec_helper"

describe Phenomenal::Context do
  
  before :each do
    @context = Phenomenal::Context.new(:test)
    @context2 = Phenomenal::Context.new(:test2)
    @manager = Phenomenal::Manager.instance
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
      context = Phenomenal::Context.new
      context.name.should be_nil
      force_forget_context(context)
    end
    
    it "should be anonymous if it is the default context" do
      Phenomenal::Manager.instance.default_context.name.should be_nil
    end
  end
  
  describe "#forget" do
    it "should raise an error if the context is active" do
      @context.activate
      expect{@context.forget}.to raise_error Phenomenal::Error
    end
    
    it "should unregister the context from the manager" do
      @context.forget
      @manager.contexts[@context].should be_nil
      @context = Phenomenal::Context.new(:test)
    end
    
    it "should raise an error if used after being forgotted" do
      @context.forget
      expect{@context.activate}.to raise_error Phenomenal::Error
      @context = Phenomenal::Context.new(:test)
    end
  end
  
  describe "#add_adaptation" do
    it "should save the default behavior in the default context" do
      @context.add_adaptation(TestString, :size,true) do
        42
      end
      a = phen_default_context.adaptations.find{|a| a.concern?(TestString,:size,true)}
      a.bind(TestString.new("1234")).should==4
    end
    
    it "should activate the adaptation if the context is active"do
      string = TestString.new("1234")
      string.size.should==4
      @context.activate
      string.size.should==4
      @context.add_adaptation(TestString, :size,true) do
        42
      end
      string.size.should==42
    end
    
    it "should  not activate the adaptation if the context is inactive"do
      string = TestString.new("1234")
      string.size.should==4
      @context.add_adaptation(TestString, :size,true) do
        42
      end
      string.size.should==4
    end
  end
  
  describe "#remove_adaptation" do
    it "should deactivate the adaptation if the context is active" do
      string = TestString.new("1234")
      string.size.should==4
      @context.activate
      @context.add_adaptation(TestString, :size,true) do
        42
      end
      string.size.should==42
      phen_remove_adaptation(:test, TestString, :size)
      string.size.should==4
      context(:test).active?.should be_true
    end
  end
  
  describe "#context" do
    it "should create a combined context of itself and the argument context" do
      c = phen_context(:test).context(:new_context)
      phen_context(:test,:new_context).should==c
      force_forget_context(:new_context)
    end
    
    describe "#phen_context" do
      it "should be an alias of #context" do
       Phenomenal::Context.instance_method(:context).should==Phenomenal::Context.instance_method(:phen_context)
      end
    end
  end
  
  describe "#feature" do
    it "should create a combined context of itself and the feature" do
      c = phen_context(:test).feature(:new_feature)
      phen_context(:test).feature(:new_feature).should==c
      force_forget_context(:new_feature)
    end
    
    describe "#phen_feature" do
      it "should be an alias of #feature" do
       Phenomenal::Context.instance_method(:feature).should==Phenomenal::Context.instance_method(:phen_feature)
      end
    end
  end
  
  describe "#add_adaptations" do
    it "should be able to adapt multiple instance method" do
      @context.should respond_to :add_adaptations
    end
  end
  
  describe "#adapatations_for" do
    it "should set the current adapted class" do
      @context.adaptations_for String
      @context.instance_variable_get("@current_adapted_class").should == String
    end
  end
  
  describe "#adapt" do
    it "should be able to adapt an instance method" do
      @context.should respond_to :adapt
    end
  end
  
  describe "#adapt_class" do
    it "should be able to adapt a  method" do
      @context.should respond_to :adapt_class
    end
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
    
    describe "#just_activated?" do
      it "should be false if the context is inactive" do
        @context.just_activated?.should be_false
      end
      
      it "should be true if the context has becamed active at the very prior activation" do
        @context.activate
        @context.just_activated?.should be_true
      end
      
      it "should be false again for the following activations" do
        @context.activate.activate
        @context.just_activated?.should be_false
      end
    end
  end
  
  describe "#anonymous?" do
    it "should be false when the context has a name" do
      @context.anonymous?.should be_false
    end
    
    it "should be true for the default context" do
      Phenomenal::Manager.instance.default_context.anonymous?.should be_true
    end
    
    it "should be true when the context has no name" do
      @context3 = Phenomenal::Context.new
      @context3.anonymous?.should be_true
      force_forget_context(@context3)
    end    
  end
  
  describe "#information" do
    it "should have all and only 6 defined fields " do
      @context.information.should have(6).items
    end
    it "should have a matching :name field" do
      @context.information[:name].should==:test
      default = Phenomenal::Manager.instance.default_context
      default.information[:name].should be_nil
    end
    it "should have a matching :adaptation field" do
      @context.information[:adaptations].should==@context.adaptations
    end
    it "should have a matching :active field" do
      @context.information[:active].should be_false
      @context.activate 
      @context.information[:active].should be_true
    end
    it "should have a matching :age field" do
      @context.activate
      @context.information[:age].should==0
      @context2.activate
      @context.information[:age].should==1
      @context2.information[:age].should==0
    end
    it "should have a matching :activation_count field" do
      @context.information[:activation_count].should==0
      @context.activate
      @context.information[:activation_count].should==1
    end

    it "should have a matching :type field" do
      @context.information[:type].should=="Phenomenal::Context"
      @feature = Phenomenal::Feature.new
      @feature.information[:type].should=="Phenomenal::Feature"
      force_forget_context(@feature)
    end
    
      
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
      
      f.forget
      context(:c).forget
    end
  end
end

