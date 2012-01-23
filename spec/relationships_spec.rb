require "spec_helper"

describe "Relationships" do
  before :each do
    @manager = Phenomenal::Manager.instance
    @feature = Phenomenal::Feature.new(:feature)
    @context_names = [:a,:b,:c,:d,:e,:f,:g]
    @ids = {}
    @context_names.each do |name|
      @feature.context(name)
      @ids[name]=@manager.linked_context_id(name)
    end
    
  end
  
  after :each  do
    force_forget_context(@feature)
    @context_names.each do |name|
      force_forget_context(name)
    end
  end
  
  describe Phenomenal::Feature do
    it "should be able to add requirements for contexts" do
      @feature.should respond_to :requirements_for
      @feature.method(:requirements_for).arity.should be(2), "Bad arity, should be 2"
    end
    it "should be able to add implications for contexts" do
      @feature.should respond_to :implications_for
      @feature.method(:implications_for).arity.should be(2), "Bad arity, should be 2"
    end
    it "should be able to add suggestions for contexts" do
      @feature.should respond_to :suggestions_for
      @feature.method(:suggestions_for).arity.should be(2), "Bad arity, should be 2"
    end
    
    describe "Requirements" do
      before :each do
        @feature.requirements_for :a, :on=>[:b,:c]
      end
    
      it "should store requirements" do
        @feature.requirements_for :a, :on=>[:b,:c,:d]
        @feature.requirements_for :a, :on=>:e
        @feature.required[:a].should include(@ids[:b],@ids[:c],@ids[:d],@ids[:e])
        @feature.required[:a].should have(4).items
      end
      
      it "should avoid activation with missing requirements" do
        phen_activate_context(:feature)
        expect {phen_activate_context(:a)}.to raise_error Phenomenal::Error
      end
      
      it "should allow activation with all requirements" do
        phen_activate_context(:feature)
        phen_activate_context(:b)
        phen_activate_context(:c)
        expect {phen_activate_context(:a)}.to_not raise_error
      end
      
      it "should deactivate source when target requirement is deactivated" do
        phen_activate_context(:feature)
        phen_activate_context(:b)
        phen_activate_context(:c)
        phen_activate_context(:a)
        expect {phen_deactivate_context(:b)}.to_not raise_error
        phen_context_active?(:a).should be_false
      end
    end
    
    describe "Implications" do
      it "should store implications" do
        @feature.implications_for :b, :on=>[:c,:d]
        @feature.implications_for :b, :on=>[:c,:d,:e]
        @feature.implications_for :b, :on=>:f
        @feature.implied[:b].should include(:c,:d,:e,:f)
        @feature.implied[:b].should have(4).items
      end
    end
    
    describe "Suggestions" do
      it "should store suggestions" do
        @feature.suggestions_for :c, :on=>[:d,:e]
        @feature.suggestions_for :c, :on=>[:d,:e,:f]
        @feature.suggestions_for :c, :on=>:g
        @feature.suggested[:c].should include(:d,:e,:f,:g)
        @feature.suggested[:c].should have(4).items
      end
    end
  end
end


#feature   
#  requirements_for :a, :on=>:x,:y,:z
#  suggestions_for :a, :on=>:x,:y,:z
#  implications_for :a, :on=>:x,:y,:z
#  exlusion_between :a,:b,:c
#end
