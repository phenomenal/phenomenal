require "spec_helper"

describe Phenomenal::ContextRelationships do
  before :each do
    @feature = Phenomenal::Feature.new :feature
    @context = @feature.context(:context)
  end
  after :each do
    force_forget_context(@feature)
    force_forget_context(context(:context))
  end
  describe "#requires" do
    it "should store the requirements in the parent feature" do
      @context.requires :b
      @feature.relationships.should have(1).item
      @feature.relationships.first.is_a?(Phenomenal::Requirement).should be_true
    end
  end
  describe "#implies" do
    it "should store the implications in the parent feature" do
      @context.implies :b
      @feature.relationships.should have(1).item
      @feature.relationships.first.is_a?(Phenomenal::Implication).should be_true
    end
  end
  describe "#suggests" do
    it "should store the suggestions in the parent feature" do
      @context.suggests :b
      @feature.relationships.should have(1).item
      @feature.relationships.first.is_a?(Phenomenal::Suggestion).should be_true
    end
  end
end
