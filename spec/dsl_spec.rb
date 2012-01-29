require "spec_helper"

describe Phenomenal::DSL do
  
  describe "#phen_define_context" do
    pending "TODO"
  end
  
  describe "#phen_context" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_context
    end
    
    pending "TODO"
    
    describe "#context" do
      it "should exist in Kernel" do 
        Kernel.should respond_to :context
      end
      
      it "should be an alias of phen_context" do
        Kernel.method(:phen_context).should == Kernel.method(:context)
      end
    end
  end
  
  describe "#phen_feature" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_feature
    end
    
    pending "TODO"
    
    describe "#feature" do
      it "should exist in Kernel" do 
        Kernel.should respond_to :feature
      end
      
      it "should be an alias of phen_context" do
        Kernel.method(:phen_feature).should == Kernel.method(:feature)
      end
    end
  end
  
  describe "#phen_forget_context" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_forget_context
    end
    
    pending "TODO"
  end
  describe "#phen_add_adaptation" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_add_adaptation
    end
    
    pending "TODO"
  end
  
  describe "#phen_add_class_adaptation" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_add_class_adaptation
    end
    
    pending "TODO"
  end
  
  describe "#phen_remove_adaptation" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_remove_adaptation
    end
    
    pending "TODO"
  end
  
  describe "#phen_remove_class_adaptation" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_remove_class_adaptation
    end
    
    pending "TODO"
  end
  
  describe "#phen_activate_context" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_activate_context
    end
    
    pending "TODO"
    
    describe "#activate_context" do
      it "should exist in Kernel" do 
        Kernel.should respond_to :activate_context
      end
      
      it "should be an alias of phen_context" do
        Kernel.method(:phen_activate_context).should == Kernel.method(:activate_context)
      end
    end
  end
  
  describe "#phen_deactivate_context" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_deactivate_context
    end
    
    pending "TODO"
    
    describe "#deactivate_context" do
      it "should exist in Kernel" do 
        Kernel.should respond_to :deactivate_context
      end
      
      it "should be an alias of phen_context" do
        Kernel.method(:phen_deactivate_context).should == Kernel.method(:deactivate_context)
      end
    end
  end
  
  describe "#phen_context_active?" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_context_active?
    end
    
    pending "TODO"
  end
  
  describe "#phen_context_information" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_context_information
    end
    
    pending "TODO"
  end
  
  describe "#phen_default_context" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_default_context
    end
    
    pending "TODO"
  end
  
  describe "#phen_defined_contexts" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_defined_contexts
    end
    
    pending "TODO"
  end
  
  describe "#phen_proceed" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_proceed
    end
    
    pending "TODO"
    
    describe "#proceed" do
      it "should exist in Kernel" do 
        Kernel.should respond_to :proceed
      end
      
      it "should be an alias of phen_context" do
        Kernel.method(:phen_proceed).should == Kernel.method(:proceed)
      end
    end
  end
  
  describe "#phen_change_conflict_policy" do
    it "should exist in Kernel" do 
      Kernel.should respond_to :phen_change_conflict_policy
    end
    
    pending "TODO"
  end
  
  describe ".phen_alias" do
    pending "TODO"
  end
end
