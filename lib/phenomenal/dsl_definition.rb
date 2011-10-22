# Define one phenomenal method for each Manager public method
module Phenomenal::DSLDefinition
  #Override included hook method
  def self.included(klass)
    # Define automaticaly the domain specific langage (dsl) keywords,
    # on the basis of the Manager public instances methods
    klass.class_eval do
      Phenomenal::Manager.instance_methods().each do |meth_name|
        dsl_keyword=meth_name.to_s.gsub!(/dsl_/, "pnml_")
        # filter only keywords definitions
        if dsl_keyword
          define_method(dsl_keyword) do |*args, &block|
            Phenomenal::Manager.instance.method(meth_name).call(*args, &block)
          end
        end
        # Define proceed manualy in order to add caller and self
        # arguments. caller is the calling stack, self the calling class
        # (Using late binding of self)
        def pnml_proceed(*args,&block)
          Phenomenal::Manager.instance.proceed(caller,self,*args,&block)
        end
      end
    end
  end
end

#Load the phenomenal primitives as top level methods
module Kernel
  include Phenomenal::DSLDefinition
end
