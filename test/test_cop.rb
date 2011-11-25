require "test/unit"
class TestCop < Test::Unit::TestCase
  private 
  def force_forget_context(context)
    while phen_context_active?(context) do
      phen_deactivate_context(context)
    end
    phen_forget_context(context)
  end
end
