require "spec_helper"
describe Phenomenal::Adaptation do
  before :each do
   define_test_classes
  end
  
  describe "#deploy" do
    it "should be able to deploy itself in instances to override default implementation" do
      adaptation = Phenomenal::Adaptation.new(nil,TestString,:length,true,Proc.new{-1})
      t = TestString.new("1234")
      t.length.should == 4
      expect {adaptation.deploy}.to_not raise_error
      t.length.should == -1
    end
    
    it "should be able to deploy itself in classes to override default implementation" do
      TestString.name.should == "TestString"
      adaptation = Phenomenal::Adaptation.new(nil,TestString,:name,false,Proc.new{"TEST"})
      expect {adaptation.deploy}.to_not raise_error
      TestString.name.should == "TEST"
    end
  end
  
  describe "#bind" do
    it "should be possible to temporary bind adapation as instance methods" do
      adaptation = Phenomenal::Adaptation.new(nil,TestString,:length,true,Proc.new{-10})
      t = TestString.new("1234")
      t.length.should == -1
      adaptation.bind(t).should == -10
      t.length.should == -1
    end
    
    it "should be possible to temporary bind adapatation as class methods" do
      TestString.name.should == "TEST"
      adaptation = Phenomenal::Adaptation.new(nil,TestString,:name,false,Proc.new{"TEST2"})
      adaptation.bind(TestString).should == "TEST2"
      TestString.name.should == "TEST"
    end
  end
  
  describe "#instance_adaptation?" do
    it "should return true if the method is a instance method" do
      adaptation = Phenomenal::Adaptation.new(nil,TestString,:length,true,Proc.new{-10})
      adaptation.instance_adaptation?.should be_true
    end
    
    it "should return false if the method is a class method" do
      adaptation = Phenomenal::Adaptation.new(nil,TestString,:name,false,Proc.new{"TEST2"})
      adaptation.instance_adaptation?.should be_false
    end
  end
  
  describe "#concern" do
   it "should return true if the adaptation concern the class n_klass and method n_method and is instance method if instance=true" do
     adaptation = Phenomenal::Adaptation.new(nil,TestString,:length,true,Proc.new{-10})
     adaptation.concern?(TestString,:length,true).should be_true
   end
   
   it "should return false if the adaptation doesn't concern the class n_klass and method n_method and is instance method if instance=true" do
     adaptation = Phenomenal::Adaptation.new(nil,TestString,:size,true,Proc.new{-10})
     adaptation.concern?(TestString,:length,true).should be_false
   end
  end
end
