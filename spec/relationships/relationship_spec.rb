require "spec_helper"

describe Phenomenal::Relationship do
  describe "#==" do
    it "should be true for two relationships with the same source and target" do
      a = Phenomenal::Relationship.new(:source,:target,nil)
      b = Phenomenal::Relationship.new(:source,:target,nil)
      a.should == b
    end
    
    it "should be false for relationships concerning different contexts" do
      a = Phenomenal::Relationship.new(:source,:target,nil)
      c = Phenomenal::Relationship.new(:source,:other_target,nil)
      a.should_not == c
      d = Phenomenal::Relationship.new(:other_source,:other_target,nil)
      a.should_not == d
      e = Phenomenal::Relationship.new(:other_source,:target,nil)
      a.should_not == e
      e = Phenomenal::Relationship.new(:other_source,:target,:test)
      a.should_not == e
    end
    
    it "should be false for relationships of different types" do
      a = Phenomenal::Implication.new(:source,:target,nil)
      b = Phenomenal::Requirement.new(:source,:target,nil)
      a.should_not == b
    end
  end
  
  describe "#refresh" do
    it "should update the references of the source and the target contexts" do
      a = Phenomenal::Implication.new(:source,:target,nil)
      expect{a.refresh}.to_not raise_error
      context :source
      context :target
      a.refresh
      a.source.should==context(:source)
      a.target.should==context(:target)
      force_forget_context(:source)
      force_forget_context(:target)
    end
  end
end
