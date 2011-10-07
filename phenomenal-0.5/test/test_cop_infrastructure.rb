require_relative "../lib/phenomenal.rb"
require "test/unit"

class TestCopInfrastructure < Test::Unit::TestCase
  def setup
    @cm = ContextManager.instance
  end

  def test_protocol
    context = Context.new(:test)
    assert(Context, "The class Context doesn't exist")
    assert(@cm, "The class @cm exist")
    assert_respond_to(context, :activate, "The activate method doesn't exist")
    assert_respond_to(context, :deactivate,
      "The deactivate method doesn't exist")
    assert_respond_to(context, :active?, "The is_active method doesn't exist")
  end

  def test_creation
    context = Context.new(:test)
    assert_kind_of(Context, context,
      "A fresh instance should be contexts indeed")
    assert(
      (context.active?.is_a?(TrueClass) || context.active?.is_a?(FalseClass)),
      "The context should be either active (true) or inactive (false).")
    assert(!context.active?, "A fresh context should not be initially active.")
  end

  def test_activation
    context_name=:test
    context = Context.new(context_name)
    assert(!context.active?, "A fresh context should not be initially active.")
    assert_equal(context_name,context.activate,
      "Context activation should return the name of the context")
    assert(context.active?,
      "Activation should leave the context in an active state")
    assert_equal(context_name,context.deactivate,
      "Context deactivation should return the name of the context")
    assert(!context.active?,
      "Deactivation should leave the context in an inactive state")
  end

  def test_redundant_activation
    context = Context.new(:test)
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
  end

  def test_redundant_deactivation
    context = Context.new(:test)
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
  end

  def test_context_name
    context_name = :test
    context = Context.new(context_name)
    assert_respond_to(context, :name, "Contexts should have a name")
    assert_equal(context_name,context.name,
      "A fresh context should be the definition name")
  end

  def test_default
   assert_nothing_raised(ContextError,"Default context should exist"){
    @cm.kw_context_informations(:default)[:name]}

    assert(@cm.kw_context_active?(:default),
      "The default context should normally be active")
  end

  def test_default_forget
    old_informations = @cm.kw_context_informations(:default)
    assert_respond_to(@cm, :kw_context_forget,
      "Method to drop unneeded contexts should exist")
    assert(@cm.kw_context_active?(:default),
      "The default context should be initialy active")
    assert_raise(ContextError,
      "An active context cannot be thrown away"){
      @cm.kw_context_forget(:default) }
	  @cm.kw_context_deactivate(:default)
    assert(!@cm.kw_context_active?(:default), "Default should be inactive")
    assert_nothing_raised(ContextError,
      "It should be possible to forget an inactive context"){
      @cm.kw_context_forget(:default) }
  	assert_nothing_raised(ContextError,
  	  %(Default context assumptions should hold for freshly
  	  created default context)){
  	  @cm.kw_context_activate(:default) }
		assert(old_informations[:creation_time]!=
		  @cm.kw_context_informations(:default)[:creation_time],
		  "Fresh default context should not be the default context just forgotten")
		assert(@cm.kw_context_active?(:default), "Default should be active")
	end

	def test_default_name
	  assert_equal(:default, @cm.kw_context_informations(:default)[:name],
	    "Context default name should be :default")
  end

  def test_adaptation_api
    assert_respond_to(@cm, :kw_context_add_adaptation,
      "Context manager should allow to adapt methods")

    assert_respond_to(@cm, :kw_context_remove_adaptation,
      "Context manager should allow to deadapt methods")
  end
end

