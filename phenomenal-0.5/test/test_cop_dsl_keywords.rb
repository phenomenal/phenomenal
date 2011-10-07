require_relative "../lib/phenomenal.rb"
require "test/unit"

class TestDslKeywords < Test::Unit::TestCase
  def test_keywords
      assert_respond_to(Object, :ctxt_activate,
        "The activate keyword doesn't exist")
      assert_respond_to(Object, :ctxt_deactivate,
        "The deactivate keyword doesn't exist")
      assert_respond_to(Object, :ctxt_forget,
        "The forget keyword doesn't exist")
      assert_respond_to(Object, :ctxt_add_adaptation,
        "The add_adaptation keyword doesn't exist")
      assert_respond_to(Object, :ctxt_remove_adaptation,
        "The remove_adaptation keyword doesn't exist")
      assert_respond_to(Object, :ctxt_active?,
        "The active? keyword doesn't exist")
      assert_respond_to(Object, :ctxt_informations,
        "The information keyword doesn't exist")
      assert_respond_to(Object, :ctxt_list,
        "The list keyword doesn't exist")
      assert_respond_to(Object, :ctxt_list_active,
        "The list_active keyword doesn't exist")
      assert_respond_to(Object, :ctxt_def,
        "The add keyword doesn't exist")
      assert_respond_to(Object, :ctxt_proceed,
        "The proceed keyword doesn't exist")
  end
end

