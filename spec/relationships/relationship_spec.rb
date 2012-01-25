require "spec_helper"

describe Phenomenal::Relationship do
  it "should be able to check equality" do
    a = Phenomenal::Relationship.new(:source,:target)
    b = Phenomenal::Relationship.new(:source,:target)
    a.should == b
    c = Phenomenal::Relationship.new(:source,:other_target)
    a.should_not == c
  end
end
