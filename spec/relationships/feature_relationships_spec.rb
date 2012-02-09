require "spec_helper"

describe Phenomenal::FeatureRelationships do
  before :each do
    @feature = Phenomenal::Feature.new :feature
  end
  after :each do
    force_forget_context(@feature)
  end
  
  describe "#requirements_for" do
    it "should store the requirements" do
      @feature.requirements_for :a,:on=>:b
      @feature.relationships.should have(1).item
      @feature.relationships.first.is_a?(Phenomenal::Requirement).should be_true
    end
  end
  describe "#implications_for" do
    it "should store the implications" do
      @feature.implications_for :a,:on=>:b
      @feature.relationships.should have(1).item
      @feature.relationships.first.is_a?(Phenomenal::Implication).should be_true
    end
  end
  describe "#suggestions_for" do
    it "should store the suggestions" do
      @feature.suggestions_for :a,:on=>:b
      @feature.relationships.should have(1).item
      @feature.relationships.first.is_a?(Phenomenal::Suggestion).should be_true
    end
  end
end
