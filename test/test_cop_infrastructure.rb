require_relative "../lib/phenomenal.rb"
require "test/unit"

class TestCopInfrastructure < Test::Unit::TestCase
  def setup
    @cm = Phenomenal::Manager.instance
    phen_change_conflict_policy { |a,b| no_resolution_conflict_policy(a,b) }
  end

  def test_protocol
    context = Phenomenal::Context.new(:test)
    assert(Phenomenal::Context, "The class Phenomenal::Context doesn't exist")
    assert(@cm, "The class @cm exist")
    assert_respond_to(context, :activate, "The activate method doesn't exist")
    assert_respond_to(context, :deactivate,
      "The deactivate method doesn't exist")
    assert_respond_to(context, :active?, "The is_active method doesn't exist")
    @cm.unregister_context(context)
  end

  def test_creation
    context = Phenomenal::Context.new(:test)
    assert_kind_of(Phenomenal::Context, context,
      "A fresh instance should be contexts indeed")
    assert(
      (context.active?.is_a?(TrueClass) || context.active?.is_a?(FalseClass)),
      "The context should be either active (true) or inactive (false).")
    assert(!context.active?, "A fresh context should not be initially active.")
    @cm.unregister_context(context)
  end

  def test_activation
    context_name=:test
    context = Phenomenal::Context.new(context_name)
    assert(!context.active?, "A fresh context should not be initially active.")
    assert_equal(context,context.activate,
      "Phenomenal::Context activation should return the context")
    assert(context.active?,
      "Activation should leave the context in an active state")
    assert_equal(context,context.deactivate,
      "Phenomenal::Context deactivation should return the context")
    assert(!context.active?,
      "Deactivation should leave the context in an inactive state")
      @cm.unregister_context(context)
  end

  def test_redundant_activation
    context = Phenomenal::Context.new(:test)
    assert(!context.active?, "A fresh context should not be initially active.")
    10.times { context.activate }
    assert(context.active?,
      "Activation should leave the context in an active state")
    9.times { context.deactivate }
    assert(context.active?,
      "Should stay active for fewer deactivations than activations")
    context.deactivate
    assert(!context.active?,
      "Should become inactive after matching number of deactivations")
      @cm.unregister_context(context)
  end

  def test_redundant_deactivation
    context = Phenomenal::Context.new(:test)
    assert(!context.active?, "A fresh context should not be initially active.")
	  3.times { context.activate }
	  assert(context.active?,
	    "Activation should leave the context in an active state")
	  9.times { context.deactivate }
    assert(!context.active?,
      "More deactivation than activation leave the context inactive")
    context.activate
    assert(context.active?,
      "Deactivation does not accumulate once the context is already inactive")
	  context.deactivate
	  assert(!context.active?,
	    "Deactivation does not accumulate once the context is already inactive")
	    @cm.unregister_context(context)
  end

  def test_context_name
    context_name = :test
    context = Phenomenal::Context.new(context_name)
    assert_respond_to(context, :name, "Contexts should have a name")
    assert_equal(context_name,context.name,
      "A fresh context should be the definition name")
      @cm.unregister_context(context)
  end

  def test_default
   assert_nothing_raised(Phenomenal::Error,"Default context should exist"){
    @cm.default_context.informations[:name]}

    assert(@cm.default_context.active?,
      "The default context should normally be active")
  end

  def test_default_forget
    old_informations = @cm.default_context.informations
    assert_respond_to(@cm, :unregister_context,
      "Method to drop unneeded contexts should exist")
    assert(@cm.default_context.active?,
      "The default context should be initialy active")
    assert_raise(Phenomenal::Error,
      "An active context cannot be thrown away"){
      @cm.default_context.forget }
	  @cm.default_context.deactivate
    assert(!@cm.default_context.active?, "Default should be inactive")
    assert_nothing_raised(Phenomenal::Error,
      "It should be possible to forget an inactive context"){
      @cm.default_context.forget }
  	assert_nothing_raised(Phenomenal::Error,
  	  %(Default context assumptions should hold for freshly
  	  created default context)){
  	  @cm.default_context.activate }
  	  #TODO
		#assert(old_informations[:creation_time]!=
		  #@cm.context_informations(:default)[:creation_time],
		  #"Fresh default context should not be the default context just forgotten")
		assert(@cm.default_context.activate, "Default should be active")
	end

  def test_adaptation_api
    assert_respond_to(@cm, :register_adaptation,
      "Phenomenal::Context manager should allow to adapt methods")

    assert_respond_to(@cm, :unregister_adaptation,
      "Phenomenal::Context manager should allow to deadapt methods")
  end
end

