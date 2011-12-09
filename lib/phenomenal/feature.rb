class Phenomenal::Feature < Phenomenal::Context
  def feature(feature,*features, &block)
    Phenomenal::Feature.create(self,feature,*features,true,&block)
  end
  alias_method :phen_feature,:feature
end
