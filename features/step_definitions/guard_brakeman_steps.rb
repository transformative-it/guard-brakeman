When /^I start guard$/ do
  run_simple('rm -f Guardfile')
  run_simple('guard init brakeman')
  run('guard')
end

When /^I edit a watched file$/ do
  append_to_file 'app/controllers/application_controller.rb', '  '
  sleep 1
end

Then /^guard should rescan the application$/ do
  type "e" # exit
  expected = /rescanning \["app\/controllers\/application_controller.rb"\], running all checks/
  expect(last_command_started).to have_output(expected)
end

Then /^guard should scan the application$/ do
  type "e" #exit
  expected = /Indexing call sites\.\.\./
  expect(last_command_started).to have_output(expected)
end

When(/^I wait for Guard to become idle$/) do
  expected = "guard(main)>"
  begin
    Timeout::timeout(aruba.config.exit_timeout) do
      loop do
        break if last_command_started.stdout.include?(expected)
        sleep 0.1
      end
    end
  rescue Timeout::Error
    STDERR.puts last_command_started.output
    fail
  end
end
