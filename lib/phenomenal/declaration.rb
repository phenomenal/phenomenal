class Phenomenal::Declaration
  
  # Catch pnml_def to define context/adaptation, use method_missing 
  # to get the caller class
  def self.method_missing(method_name, *args, &block)  
    if method_name==:pnml_def
      context_name=self.class.name
      if not Phenomenal::Manager.instance.context_defined?(context_name)
        Phenomenal::Context.new(context_name)   
      end
      Phenomenal::Manager.instance.find_context(context_name).add_adaptation(
         args[0], args[1], &block
       )
     else
       super
    end
  end
end