require "spec_helper"

describe Phenomenal::RelationshipsStore do
  before :each do
    @source = context :source
    @target = context :target
    @relationship = Phenomenal::Relationship.new(:source,:target,phen_default_context)
    @relationship2 = Phenomenal::Relationship.new(:source2,:target2,phen_default_context)
    @relationship12 = Phenomenal::Relationship.new(:source,:target2,phen_default_context)
    @store = Phenomenal::RelationshipsStore.new
  end
  
  after :each do
    force_forget_context(@source)
    force_forget_context(@target)
  end
  
  describe "#add" do
    it "should add the relationship to the store" do
      @store.add(@relationship)
      @store.include?(@relationship).should be_true
    end
  end
  
  describe "#remove" do
    it "should remove the relationship from the store" do
      @store.add(@relationship)
      @store.remove(@relationship)
      @store.include?(@relationship).should be_false
    end
  end
  
  describe "#get_for" do
    it "should return the relationships that concern the target" do
      @store.add(@relationship)
      @store.add(@relationship2)
      @store.add(@relationship12)
      @store.get_for(@source).should include(@relationship)
      @store.get_for(@source).should include(@relationship12)
      @store.get_for(@source).should_not include(@relationship2)
    end
  end
end
