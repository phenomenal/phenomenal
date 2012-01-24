require "spec_helper"

describe "Relationships" do
  before :each do
    @manager = Phenomenal::Manager.instance
    @feature = Phenomenal::Feature.new(:feature)
    @context_names = [:a,:b,:c,:d,:e,:f,:g]
    @context_names.each do |name|
      @feature.context(name)
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
#    it "should be able to add implications for contexts" do
#      @feature.should respond_to :implications_for
#      @feature.method(:implications_for).arity.should be(2), "Bad arity, should be 2"
#    end
#    it "should be able to add suggestions for contexts" do
#      @feature.should respond_to :suggestions_for
#      @feature.method(:suggestions_for).arity.should be(2), "Bad arity, should be 2"
#    end
    
    describe "Requirements" do
      before :each do
        @feature.requirements_for :a, :on=>[:b,:c]
      end
    
      it "should store requirements" do
        @feature.requirements_for :a, :on=>[:b,:c,:d]
        @feature.requirements_for :a, :on=>:e
        @feature.relationships.should have(4).items
      end
      
      it "should avoid activation with missing requirements" do
        phen_activate_context(:feature)
        expect {phen_activate_context(:a)}.to raise_error Phenomenal::Error
        phen_context_active?(:a).should be_false
      end
      
      it "should allow activation with all requirements" do
        phen_activate_context(:feature)
        phen_activate_context(:b)
        phen_activate_context(:c)
        expect {phen_activate_context(:a)}.to_not raise_error
        phen_context_active?(:a).should be_true
      end
      
      it "should deactivate source when target requirement is deactivated" do
        phen_activate_context(:feature)
        phen_activate_context(:b)
        phen_activate_context(:c)
        phen_activate_context(:a)
        expect {phen_deactivate_context(:b)}.to_not raise_error
        phen_context_active?(:a).should be_false
      end
      
      it "should avoid feature activation when it add a not satisfied requirement" do
        phen_activate_context(:a)
        expect {phen_activate_context(:feature)}.to raise_error Phenomenal::Error
        phen_context_active?(:feature).should be_false
      end
      
      after do
        @manager.default_context.deactivate
        @manager.default_context.forget
      end
      it "should be possible to add requirements to the default context" do
        requirements_for :a, :on=>[:b,:c,:d]
        requirements_for :a, :on=>:e
        @manager.default_context.relationships.should have(4).items
      end
      
      it "should be possible to put requirements in the nested contexts" do
        c=nil
        f = feature :feature2 do 
          c=context :a do
            requires :b
          end
        end
        f.relationships.should have(1).items
      end
      
      it "should be possible to put requirements in combined nested contexts" do
        c=nil
        f= feature :feature3 do 
          c=context :a,:b do
            requires :c
          end
        end
        f.relationships.should have(2).items
      end
    end
    
#    describe "Implications" do
#      it "should store implications" do
#        @feature.implications_for :b, :on=>[:c,:d]
#        @feature.implications_for :b, :on=>[:c,:d,:e]
#        @feature.implications_for :b, :on=>:f
#        @feature.implied[:b].should include(:c,:d,:e,:f)
#        @feature.implied[:b].should have(4).items
#      end
#    end
#    
#    describe "Suggestions" do
#      it "should store suggestions" do
#        @feature.suggestions_for :c, :on=>[:d,:e]
#        @feature.suggestions_for :c, :on=>[:d,:e,:f]
#        @feature.suggestions_for :c, :on=>:g
#        @feature.suggested[:c].should include(:d,:e,:f,:g)
#        @feature.suggested[:c].should have(4).items
#      end
#    end
  end
end


#feature   
#  requirements_for :a, :on=>:x,:y,:z
#  suggestions_for :a, :on=>:x,:y,:z
#  implications_for :a, :on=>:x,:y,:z
#  exlusion_between :a,:b,:c
#end
