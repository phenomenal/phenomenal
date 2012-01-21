require 'rspec'
require "phenomenal"

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end

def force_forget_context(context)
  while phen_context_active?(context) do
    phen_deactivate_context(context)
  end
  phen_forget_context(context)
end
