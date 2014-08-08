require 'rspec'
require 'guard/brakeman'

RSpec.configure do |config|
  config.before(:each) do
    @lib_path        = Pathname.new(File.expand_path('../../lib/', __FILE__))
  end
end