# Define one phenomenal method for each Manager public method
module Phenomenal
  #Override included hook method
  def self.included(klass)
    # Define automaticaly the domain specific langage (dsl) keywords,
    # on the basis of the Manager public instances methods
    klass.class_eval do
      Phenomenal::Manager.instance_methods(false).each do |meth_name|
        dsl_keyword="pnml_"+meth_name.to_s
        # filter only keywords definitions
        if dsl_keyword!="pnml_proceed"
          define_method(dsl_keyword) do |*args, &block|
            Phenomenal::Manager.instance.method(meth_name).call(*args, &block)
          end
        else
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
end

#Load the phenomenal primitives as top level methods
module Kernel
  include Phenomenal
end
