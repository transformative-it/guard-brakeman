require 'guard/compat/test/helper'
require 'guard/brakeman'

# TODO
# Barely covers happy case, ignores sad case
# Pending tests
RSpec.describe Guard::Brakeman do
  let(:default_options) { {:cli => '--stuff'} }
  let(:tracker) { double("tracker") }
  let(:report) { double("report").as_null_object }

  before(:each) do
    @guard = Guard::Brakeman.new
    allow(@guard).to receive(:decorate_warning)
    @guard.instance_variable_set(:@tracker, tracker)
    @guard.instance_variable_set(:@options, {:notifications => false, :app_path => 'tmp/aruba/default_app'})
    allow(Guard::Compat::UI).to receive(:color).and_return("foo")
    allow(Guard::Compat::UI).to receive(:info)
  end

  describe '#start' do
    let(:scanner) { double(:process => tracker) }

    it 'initializes brakeman by scanning all files' do
      allow(::Brakeman::Scanner).to receive(:new).and_return(scanner)
      expect(scanner).to receive(:process)
      @guard.start
    end

    context 'with the run_on_start option' do
      before(:each) do
        @guard.instance_variable_set(:@options, @guard.instance_variable_get(:@options).merge({:run_on_start => true}))
      end

      it 'runs all checks' do
        allow(scanner).to receive(:process).and_return(tracker)
        expect(@guard).to receive(:run_all)
        @guard.start
      end
    end

    context 'with the exclude option' do
      let(:options) { {:skip_checks => ['CheckDefaultRoutes']} }
      before(:each) do
        @guard.instance_variable_set(:@options, @guard.instance_variable_get(:@options).merge(options))
      end

      it 'does not run the specified checks' do
        expect(::Brakeman::Scanner).to receive(:new).with(hash_including(options)).and_return(scanner)
        @guard.start
      end
    end
  end

  describe '#run_all' do
    it 'runs all checks' do
      allow(@guard).to receive(:print_failed)
      expect(tracker).to receive(:run_checks)
      allow(tracker).to receive_message_chain(:checks, :all_warnings).and_return([])
      expect(tracker).to receive(:filtered_warnings).and_return([])
      expect(::Brakeman).to receive(:filter_warnings).with(tracker, anything)
      @guard.run_all
    end
  end

  describe '#reload'

  describe '#run_on_change' do
    it 'rescans changed files, and checks all files' do
      expect(::Brakeman).to receive(:rescan).with(tracker, ['files/file']).and_return(report)
      allow(report).to receive(:any_warnings?)
      expect(tracker).to receive(:checks).and_return([double("check")])
      @guard.run_on_changes(['files/file'])
    end
  end

  describe '#print_failed' do
    before(:each) do
      allow(report).to receive(:all_warnings).and_return [double(:confidence => 0)]
    end

    context 'with the chatty flag' do
      before(:each) do
        @guard.instance_variable_set(:@options, {:chatty => true})
      end

      it 'notifies the user' do
        expect(::Guard::Notifier).to receive :notify
        @guard.send :print_failed, report
      end
    end

    context 'with the output option' do
      before(:each) do
        @guard.instance_variable_set(:@options, {:output_files => ['test.csv']})
      end

      it 'writes the brakeman report to disk' do
        expect(@guard).to receive(:write_report)
        @guard.send :print_failed, report
      end

      it 'adds the report filename to the growl' do
        allow(@guard).to receive(:write_report)
        @guard.instance_variable_set(:@options, @guard.instance_variable_get(:@options).merge({:chatty => true}))
        expect(Guard::Compat::UI).to receive(:notify).with(/test\.csv/, anything)
        @guard.send :print_failed, report
      end
    end

    context 'with notifications disabled' do
      before(:each) do
        @guard.instance_variable_set(:@options, {:chatty => false})
      end

      it 'does not notify the user' do
        expect(::Guard::Compat::UI).not_to receive :notify
        @guard.send :print_failed, report
      end
    end
  end

  describe '#print_changed' do
    before(:each) do
      allow(report).to receive(:all_warnings).and_return [double(:confidence => 3)]
    end

    context 'with the min_confidence setting' do
      let(:options) { {:min_confidence => 2} }
      before(:each) do
        @guard.instance_variable_set(:@options, @guard.instance_variable_get(:@options).merge(options))
      end

      it 'does not alert on warnings below the threshold' do
        expect(Guard::Compat::UI).not_to receive :notify
        @guard.send :print_changed, report
      end
    end

    context 'with notifications on' do
      before(:each) do
        @guard.instance_variable_set(:@options, {:notifications => true})
      end

      it 'notifies the user' do
        expect(Guard::Compat::UI).to receive :notify
        @guard.send :print_changed, report
      end
    end

    context 'with notifications disabled' do
      before(:each) do
        @guard.instance_variable_set(:@options, {:notifications => false})
      end

      it 'does not notify the user' do
        expect(Guard::Compat::UI).not_to receive :notify
        @guard.send :print_changed, report
      end
    end

    context 'with the output option' do
      before(:each) do
        @guard.instance_variable_set(:@options, {:output_files => ['test.csv']})
      end

      it 'writes the brakeman report to disk' do
        expect(File).to receive(:open).with('test.csv', 'w')
        @guard.send :print_changed, report
      end

      it 'adds the report filename to the growl' do
        allow(@guard).to receive(:write_report)
        @guard.instance_variable_set(:@options, @guard.instance_variable_get(:@options).merge({:notifications => true}))
        expect(::Guard::Notifier).to receive(:notify).with(/test\.csv/, anything)
        @guard.send :print_changed, report
      end
    end
  end

  describe "#write_report" do
    it 'writes the report to disk' do
      @guard.instance_variable_set(:@options, {:output_files => ['test.csv']})

      expect(File).to receive(:open).with('test.csv', 'w')
      @guard.send(:write_report)
    end
  end
end
