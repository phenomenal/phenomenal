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
    @manager.default_context.deactivate
    @manager.default_context.forget
  end
  
  describe Phenomenal::Feature do
    it "should be able to add requirements for contexts" do
      @feature.should respond_to :requirements_for
      @feature.method(:requirements_for).arity.should be(2),
      "Bad arity, should be 2"
    end
    it "should be able to add implications for contexts" do
      @feature.should respond_to :implications_for
      @feature.method(:implications_for).arity.should be(2),
      "Bad arity, should be 2"
    end
    it "should be able to add suggestions for contexts" do
      @feature.should respond_to :suggestions_for
      @feature.method(:suggestions_for).arity.should be(2),
      "Bad arity, should be 2"
    end
    
    describe "Requirements" do
      it "should store requirements" do
        @feature.requirements_for :a, :on=>[:b,:c,:d]
        @feature.requirements_for :a, :on=>:e
        @feature.relationships.should have(4).items
      end
      
      it "should avoid activation with missing requirements" do
        @feature.requirements_for :a, :on=>[:b,:c]
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
        @feature.requirements_for :a, :on=>[:b,:c]
        phen_activate_context(:feature)
        phen_activate_context(:b)
        phen_activate_context(:c)
        phen_activate_context(:a)
        expect {phen_deactivate_context(:b)}.to_not raise_error
        phen_context_active?(:a).should be_false
      end
      
      it "should avoid feature activation when adding a not satisfied requirement" do
        @feature.requirements_for :a, :on=>[:b,:c]
        phen_activate_context(:a)
        expect{phen_activate_context(:feature)}.to_not raise_error
        phen_context_active?(:feature).should be_false
      end
      
      it "should be possible to add requirements to the default context" do
        requirements_for :a, :on=>[:b,:c,:d]
        requirements_for :a, :on=>:e
        @manager.default_context.relationships.should have(4).items
      end
      
      it "should be possible to put requirements in the nested contexts" do
        feature :feature do 
          context :a do
            requires :b
          end
        end
        @feature.relationships.should have(1).items
      end
      
      it "should be possible to put requirements in combined nested contexts" do
        feature :feature do 
          context :a,:b do
            requires :c,:d,:e
          end
        end
        @feature.relationships.should have(3).items
      end
    end
    describe "Implications" do
      it "should store implications" do
        @feature.implications_for :a, :on=>[:b,:c,:d]
        @feature.implications_for :a, :on=>:e
        @feature.relationships.should have(4).items
      end
      
      it "should activate target when source is activated" do
        @feature.implications_for :a, :on=>:b
        @feature.activate
        expect {phen_activate_context(:a)}.to_not raise_error
        phen_context_active?(:a).should be_true
        phen_context_active?(:b).should be_true
      end
      
      it "should deactivate target when source is deactivated" do
        @feature.implications_for :a, :on=>:b
        @feature.activate
        phen_activate_context(:a)
        phen_deactivate_context(:a)
        phen_context_active?(:b).should be_false
      end
      
      it "should deactivate source when target is deactivated" do
        @feature.implications_for :a, :on=>:b
        @feature.activate
        phen_activate_context(:a)
        phen_deactivate_context(:b)
        phen_context_active?(:a).should be_false
      end
      
      it "should be possible to put implications in the nested contexts" do
        feature :feature do 
          context :a do
            implies :b
          end
        end
        @feature.relationships.should have(1).items
      end
      
      it "should be possible to put implications in combined nested contexts" do
        feature :feature do 
          context :a,:b do
            implies :c,:d,:e
          end
        end
        @feature.relationships.should have(3).items
      end
    end
    
    describe "Suggestions" do
      it "should be working on the default feature" do
        suggestions_for :a,:on=>:b
        @manager.default_context.relationships.should have(1).items
        context(:a).active?.should be_false
        context(:b).active?.should be_false
        expect {activate_context :a}.to_not raise_error
        context(:a).active?.should be_true
        context(:b).active?.should be_true
        expect {deactivate_context :a}.to_not raise_error
        context(:a).active?.should be_false
        context(:b).active?.should be_false
      end
      
      it "should be possible to add relationships on active features" do
        context(:a).active?.should be_false
        context(:b).active?.should be_false
        expect {activate_context :a}.to_not raise_error
        suggestions_for :a,:on=>:b
        @manager.default_context.relationships.should have(1).items
        context(:a).active?.should be_true
        context(:b).active?.should be_true
        expect {deactivate_context :a}.to_not raise_error
        context(:a).active?.should be_false
        context(:b).active?.should be_false
      end
      
      it "should apply the relationship on the activation of the feature that contain it" do
        context(:a).active?.should be_false
        context(:b).active?.should be_false
        expect {activate_context :a}.to_not raise_error
        @feature.suggestions_for :a,:on=>:b
        context(:a).active?.should be_true
        context(:b).active?.should be_false
        expect {activate_context @feature}.to_not raise_error
        context(:a).active?.should be_true
        context(:b).active?.should be_true
        expect {deactivate_context @feature}.to_not raise_error
        context(:a).active?.should be_true
        context(:b).active?.should be_false
      end
      
      it "should store suggestions" do
        @feature.suggestions_for :a, :on=>[:b,:c,:d]
        @feature.suggestions_for :a, :on=>:e
        @feature.relationships.should have(4).items
      end
      
      it "should activate target when source is activated" do
        @feature.suggestions_for :a, :on=>:b
        @feature.activate
        expect {phen_activate_context(:a)}.to_not raise_error
        phen_context_active?(:a).should be_true
        phen_context_active?(:b).should be_true
      end
      
      it "should deactivate target when source is deactivated" do
        @feature.suggestions_for :a, :on=>:b
        @feature.activate
        phen_activate_context(:a)
        phen_deactivate_context(:a)
        phen_context_active?(:b).should be_false
      end
      
      it "should not deactivate source when target is deactivated" do
        @feature.suggestions_for :a, :on=>:b
        @feature.activate
        phen_activate_context(:a)
        phen_deactivate_context(:b)
        phen_context_active?(:a).should be_true
      end
      
      it "should be possible to put suggestions in the nested contexts" do
        feature :feature do 
          context :a do
            suggests :b
          end
        end
        @feature.relationships.should have(1).items
      end
      
      it "should be possible to put suggestions in combined nested contexts" do
        feature :feature do 
          context :a,:b do
            suggests :c,:d,:e
          end
        end
        @feature.relationships.should have(3).items
      end
    end
  end
end
