require "spec_helper"

describe Phenomenal::DSL do
  describe "#requirements_for" do
   it "should exist in Kernel" do 
      Kernel.should respond_to :requirements_for
    end
  end
  describe "#implications_for" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :implications_for
    end
  end
  describe "#suggestions_for" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :suggestions_for
    end
  end
end
