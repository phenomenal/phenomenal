class Phenomenal::Feature < Phenomenal::Context
  def self.create(*args,&block)
    feature = super(*args,&block)
    feature
  end
  def feature(context,*contexts,&block)
    contexts.insert(0, context)
    Phenomenal::Context.create_feature(self,*contexts,&block)
  end
end
