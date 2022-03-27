# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::CLI::Parsers::Core do
  subject(:parser) { described_class.new configuration.dup }

  include_context "with application dependencies"
  include_context "with temporary directory"

  it_behaves_like "a parser"

  describe "#call" do
    it "answers analyze (short)" do
      expect(parser.call(%w[-a])).to have_attributes(action_analyze: true)
    end

    it "answers analyze (long)" do
      expect(parser.call(%w[--analyze])).to have_attributes(action_analyze: true)
    end

    it "answers config edit (short)" do
      expect(parser.call(%w[-c edit])).to have_attributes(action_config: :edit)
    end

    it "answers config edit (long)" do
      expect(parser.call(%w[--config edit])).to have_attributes(action_config: :edit)
    end

    it "answers config view (short)" do
      expect(parser.call(%w[-c view])).to have_attributes(action_config: :view)
    end

    it "answers config view (long)" do
      expect(parser.call(%w[--config view])).to have_attributes(action_config: :view)
    end

    it "fails with missing config action" do
      expectation = proc { parser.call %w[--config] }
      expect(&expectation).to raise_error(OptionParser::MissingArgument, /--config/)
    end

    it "fails with invalid config action" do
      expectation = proc { parser.call %w[--config bogus] }
      expect(&expectation).to raise_error(OptionParser::InvalidArgument, /bogus/)
    end

    it "answers Git Hook" do
      expect(parser.call(%W[--hook #{temp_dir}])).to have_attributes(action_hook: temp_dir)
    end

    it "fails with missing Git Hook path" do
      expectation = proc { parser.call %w[--hook] }
      expect(&expectation).to raise_error(OptionParser::MissingArgument, /--hook/)
    end

    it "answers version (short)" do
      configuration = parser.call %w[-v]
      expect(configuration.action_version).to be(true)
    end

    it "answers version (long)" do
      configuration = parser.call %w[--version]
      expect(configuration.action_version).to be(true)
    end

    it "enables help (short)" do
      expect(parser.call(%w[-h])).to have_attributes(action_help: true)
    end

    it "enables help (long)" do
      expect(parser.call(%w[--help])).to have_attributes(action_help: true)
    end
  end
end
