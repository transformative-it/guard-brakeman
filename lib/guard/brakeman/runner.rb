require 'brakeman'

module Guard
  class Brakeman

    # The Cucumber runner handles the execution of the cucumber binary.
    #
    module Runner
      class << self

        # Run the supplied features.
        #
        # @param [Array<String>] paths the feature files or directories
        # @param [Hash] options the options for the execution
        # @option options [Boolean] :bundler use bundler or not
        # @option options [Array<String>] :rvm a list of rvm version to use for the test
        # @option options [Boolean] :notification show notifications
        # @return [Boolean] the status of the execution
        #
        def run(paths, tracker, options = { })
          return false if paths.empty?

          message = options[:message] || (paths == ['.'] ? 'Run brakeman on the whole project' : "Run brakeman checks #{ paths.join(' ') }")
          UI.info message, :reset => true

          # system(brakeman_command(paths, options))
          changed = ::Brakeman.rescan(tracker, paths)
          if changed
            tracker.run_checks
            changed
          end
        end

        private

        # Assembles the Cucumber command from the passed options.
        #
        # @param [Array<String>] paths the feature files or directories
        # @param [Hash] options the options for the execution
        # @option options [Boolean] :bundler use bundler or not
        # @option options [Array<String>] :rvm a list of rvm version to use for the test
        # @option options [Boolean] :notification show notifications
        # @return [String] the Cucumber command
        #
        def brakeman_command(paths, options)
          cmd = []
          cmd << "rvm #{options[:rvm].join(',')} exec" if options[:rvm].is_a?(Array)
          cmd << 'bundle exec' if bundler? && options[:bundler] != false

          cmd << 'brakeman'
          cmd << options[:cli] if options[:cli]
          cmd << "-o #{options[:output]}" if options[:output]

          if options[:notification] != false
            # notification_formatter_path = File.expand_path(File.join(File.dirname(__FILE__), 'notification_formatter.rb'))
            # cmd << "--require #{ notification_formatter_path }"
            # cmd << "--format Guard::Cucumber::NotificationFormatter"
            # cmd << "--out #{ null_device }"
            # cmd << "--require features"
          end

          (cmd + paths).join(' ')
        end

        # Simple test if bundler should be used. it just checks for the `Gemfile`.
        #
        # @return [Boolean] bundler exists
        #
        def bundler?
          @bundler ||= File.exist?("#{Dir.pwd}/Gemfile")
        end

        # Returns a null device for all OS.
        #
        # @return [String] the name of the null device
        #
        def null_device
          RUBY_PLATFORM.index('mswin') ? 'NUL' : '/dev/null'
        end

      end
    end
  end
end
