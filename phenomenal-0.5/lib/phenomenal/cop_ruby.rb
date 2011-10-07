# Define one ctxt_*** method for each ContextManager.kw_context_***
# method
module CopRuby
  #Override included hook method
  def self.included(klass)
    # Define automaticaly the domain specific langage (dsl) keywords,
    # on the basis of the ContextManager.kw_context_... instances methods
    klass.class_eval do
      ContextManager.instance_methods.each do |meth_name|
        dsl_keyword=meth_name.to_s.gsub!(/kw_context_/, "ctxt_")
        # filter only keywords definitions
        if dsl_keyword && dsl_keyword!="ctxt_proceed"
          define_method(dsl_keyword) do |*args, &block|
            ContextManager.instance.method(meth_name).call(*args, &block)
          end
        elsif dsl_keyword=="ctxt_proceed"
          # Define ctxt_proceed manualy in order to add caller and self
          # arguments. caller is the calling stack, self the calling class
          # (Using late binding of self)
          def ctxt_proceed(*args,&block)
           ContextManager.instance.kw_context_proceed(caller,self,*args,&block)
          end
        end
      end
    end
  end
end

