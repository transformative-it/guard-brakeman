When /^I start guard$/ do
  run_simple('rm -f Guardfile')
  run_simple('guard init brakeman')
  @interactive = run('guard')
end

When /^I edit a watched file$/ do
  append_to_file 'app/controllers/application_controller.rb', '  '
  sleep 1
end

Then /^guard should rescan the application$/ do
  interactive = @interactive
  interactive.write("e\n") #exit
  expected = /rescanning \["app\/controllers\/application_controller.rb"\], running all checks/
  expect(interactive).to have_output(expected)
end

Then /^guard should scan the application$/ do
  interactive = @interactive
  interactive.write("e\n") #exit
  expected = /Indexing call sites\.\.\./
  expect(interactive).to have_output(expected)
end

When(/^I wait for Guard to become idle$/) do
  interactive = @interactive
  expected = "guard(main)>"
  begin
    Timeout::timeout(aruba.config.exit_timeout) do
      loop do
        break if interactive.stdout.include?(expected)
        sleep 0.1
      end
    end
  rescue Timeout::Error
    STDERR.puts interactive.output
    fail
  end
end
