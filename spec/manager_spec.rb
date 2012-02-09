require "spec_helper"

describe Phenomenal::Manager do
  before :each do
    @context = Phenomenal::Context.new(:test)
    @context2 = Phenomenal::Context.new(:test2)
    @combined = context :test,:test2
    @manager = Phenomenal::Manager.instance
  end
  
  after :each  do
    force_forget_context(@context)
    force_forget_context(@context2)
  end
  
  describe "#register_context" do
    it "should save the context when they are defined" do
      @manager.contexts[@context].should==@context
    end
    
    it "should raise an error if we declare a context with a name already used" do
      #expect{Phenomenal::Context.new(:test)}.to raise_error Phenomenal::Error
    end
    
    it "should raise an error if we try to register a context twice" do
      expect{@manager.register_context(@context)}.to raise_error Phenomenal::Error
    end
  end
  
  describe "#unregister_context" do
    it "should remove contexts from the manager" do
      context = Phenomenal::Context.new(:context)
      expect{@manager.unregister_context(context)}.to_not raise_error
      @manager.contexts[context].should be_nil
    end
    
    it "should allow to forget default context only when it is the only defined context" do
      @manager.contexts.size.should==4
      expect{@manager.unregister_context(@manager.default_context)}.to raise_error Phenomenal::Error
      force_forget_context(@context)
      force_forget_context(@context2)
      @manager.contexts.size.should==1
      expect{@manager.unregister_context(@manager.default_context)}.to_not raise_error
      @context = Phenomenal::Context.new(:test)
      @context2 = Phenomenal::Context.new(:test2)
    end
  end
  
  describe "#change_conflict_policy" do
    it "should be possible to change the conflict policy" do
      @manager.should respond_to :change_conflict_policy
    end
  end
  
  describe "#find_context" do
    it "should return the simple context with the name passed as parameter" do
      @manager.find_context(:test).should==@context
    end
    
    it "should raise an error if the context wasn't found" do
      expect {@manager.find_context(:unknown)}.to raise_error Phenomenal::Error
    end
    
    it "should return the context immediatly if the argument is a context an is known by the manager" do
      @manager.find_context(@context).should==@context
    end
    
    it "should return the combined context matching the list of names passed as parameters" do
      @manager.find_context(:test,:test2).should==@combined
    end
  end
  
  describe "#context_defined?" do
    it "should return the context if the context exist" do
      @manager.context_defined?(:test).should==@context
    end
    
    it "should return nil if the context doesn't exist" do
      context = Phenomenal::Context.new(:context)
      @manager.context_defined?(:context).should==context
      context.forget
      @manager.context_defined?(:context).should be_nil
      @manager.context_defined?(:unknown).should be_nil
    end
    
    it "should work with context references" do 
       @manager.context_defined?(@context).should==@context
    end
    
    it "should work with combined contexts" do
      @manager.context_defined?(:test,:test2).should==@combined
      @manager.context_defined?(:test,:unknown).should be_nil
    end
  end
end
