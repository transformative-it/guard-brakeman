require File.expand_path('../../../lib/guard/brakeman',  __FILE__)
require 'aruba/cucumber'

Before do
  @aruba_timeout_seconds = 20
end


After do
  content = <<-EOF
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
	EOF

  path = 'app/controllers/application_controller.rb'
  overwrite_file(path, content)
end
