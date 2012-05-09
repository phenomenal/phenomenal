require "../lib/phenomenal"
require "../spec/test_classes.rb"

    context(:quiet) do
      adaptations_for Phone
      adapt :advertise do |a_call|
        "vibrator"
      end 
    end
    
    context(:offHook) do
      adaptations_for Phone
      adapt :advertise do |a_call|
        "call waiting signal"
      end 
    end

    
    context(:test) do
      adaptations_for TestClass
      adapt :to_s do
        @value + " @access " + value + " attr_accessor_access"
      end
    end
    
    context(:test_2) do
      adaptations_for TestClass
      adapt_class :klass_var_access do
        @@klass_var+1
      end
    end

    context(:test_3) do
      adaptations_for TestClass
      adapt_class :klass_inst_var_access do
        @klass_inst_var+1
      end
    end



phen_add_adaptation(:test,Phone,:phonyAdvertise){|a_call| "vibrator"}

  
