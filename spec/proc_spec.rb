require "spec_helper"

describe Proc do
  it "should be possible to bind proc as instance methods" do
    p = Proc.new{"Proc"}
    p.should respond_to :phenomenal_bind
    o = BasicObject.new
    p.phenomenal_bind(o).call.should == "Proc"
  end
  
  it "should be possible to bind proc as class methods" do
    p = Proc.new{"Proc"}
    p.should respond_to :phenomenal_class_bind
    p.phenomenal_bind(BasicObject).call.should == "Proc"
  end
end
