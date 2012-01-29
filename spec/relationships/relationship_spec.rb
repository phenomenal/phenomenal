require "spec_helper"

describe Phenomenal::Relationship do
  describe "#==" do
    it "should be true for two relationships with the same source and target" do
      a = Phenomenal::Relationship.new(:source,:target)
      b = Phenomenal::Relationship.new(:source,:target)
      a.should == b
    end
    
    it "should be false for relationships concerning different contexts" do
      a = Phenomenal::Relationship.new(:source,:target)
      c = Phenomenal::Relationship.new(:source,:other_target)
      a.should_not == c
      d = Phenomenal::Relationship.new(:other_source,:other_target)
      a.should_not == d
      e = Phenomenal::Relationship.new(:other_source,:target)
      a.should_not == e
    end
    
    it "should be false for relationships of different types" do
      a = Phenomenal::Implication.new(:source,:target)
      b = Phenomenal::Requirement.new(:source,:target)
      a.should_not == b
    end
  end
  
  describe "#refresh" do
    pending "TODO"
  end
end
