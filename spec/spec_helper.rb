require 'rspec'
require "phenomenal"
require "test_classes.rb"

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'progress'
end

def force_forget_context(context)
  while phen_context_active?(context) do
    phen_deactivate_context(context)
  end
  phen_forget_context(context)
end

def define_test_classes
  load "test_classes.rb"
end
