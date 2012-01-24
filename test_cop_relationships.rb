require_relative "../lib/phenomenal.rb"
require_relative "./test_classes.rb"
require_relative "./test_cop.rb"

class TestCopRelationShips < TestCop
  def setup
    context :quiet 
    context :museum
    context :brussels
    context :belgium
    context :hdvideo
    context :highbattery
  end

  def teardown
    force_forget_context(:quiet)
    force_forget_context(:museum)
    force_forget_context(:brussels)
    force_forget_context(:belgium)
    force_forget_context(:hdvideo)
    force_forget_context(:highbattery)
  end

  def test_suggestions_1
    context :museum do
      suggests :quiet
    end
    activate_context(:museum)
    assert(phen_context_active?(:quiet),
    "The quiet context should be activated by the museum context")
  end
  
  def test_suggestions_2
    context :museum do
      suggests :quiet
    end
    activate_context(:museum)
    deactivate_context(:museum)
    assert(!phen_context_active?(:quiet),
    "The quiet context should be deactivated by the museum context")
  end
  
  def test_suggestions_3
    context :museum do
      suggests :quiet
    end
    activate_context(:museum)
    deactivate_context(:quiet)
    assert(!phen_context_active?(:quiet),
    "The quiet context should be deactivated")
    assert(phen_context_active?(:museum),
    "The museum context should stay active after quiet context deactivation")
    deactivate_context(:museum)
    assert(!phen_context_active?(:museum),
    "The museum context be inactive")
  end
  
  def test_implications_1
    context :brussels do
      implies :belgium
    end
    activate_context(:brussels)
    assert(phen_context_active?(:belgium),
    "The belgium context should be activated by the brussels context")
  end
  
  def test_implication_2
    context :brussels do
      implies :belgium
    end
    activate_context(:belgium)
    assert(!phen_context_active?(:brussels),
    "The brussels context should not be activated by the belgium context")    
  end
  
  def test_implication_3
    context :brussels do
      implies :belgium
    end
    activate_context(:brussels)
    deactivate_context(:brussels)
    assert(!phen_context_active?(:belgium),
    "The belgium context should be deactivated by the brussels context")
  end
  
  def test_implication_3
    context :brussels do
      implies :belgium
    end
    activate_context(:brussels)
    activate_context(:belgium)
    activate_context(:belgium)
    deactivate_context(:brussels)
    assert(phen_context_active?(:belgium),
    "The belgium context should not be deactivated by the brussels context")
  end
  
  def test_requirements_1
    context :hdvideo do
      requires :highbattery
    end
    assert_raise(Phenomenal::Error,
    "The hd video should not be activated without the highbattery context") do
      activate_context(:hdvideo)
    end
  end
  
  def test_requirements_2
    context :hdvideo do
      requires :highbattery
    end
    activate_context(:highbattery)
    assert_nothing_raised(Phenomenal::Error, "The hdvideo context should be"+ 
    "activated without error") do
      activate_context(:hdvideo)
    end
  end
  
  def test_requirements_3
    context :hdvideo do
      requires :highbattery
    end
    activate_context(:highbattery)
    activate_context(:hdvideo)
    activate_context(:highbattery)
    deactivate_context(:highbattery)
    deactivate_context(:highbattery)
    assert(!phen_context_active?(:hdvideo), "The hdvideo context should have "+
    "been deactivated by the deactivation of highbattery")
  end
end

