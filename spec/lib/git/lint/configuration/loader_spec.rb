# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Configuration::Loader do
  subject(:loader) { described_class.with_defaults }

  let :configuration do
    Git::Lint::Configuration::Content[
      action_analyze: nil,
      action_config: nil,
      action_help: nil,
      action_hook: nil,
      action_version: nil,
      analyze_sha: nil,
      analyzers:
    ]
  end

  let :analyzers do
    Bundler.root
           .join("lib/git/lint/configuration/defaults.yml")
           .then { |path| YAML.load_file path }
           .then { |defaults| defaults.fetch :analyzers }
           .map { |id, defaults| Git::Lint::Configuration::Setting[id:, **defaults] }
  end

  describe ".call" do
    it "answers default configuration" do
      expect(described_class.call).to be_a(Git::Lint::Configuration::Content)
    end
  end

  describe ".with_defaults" do
    it "answers default configuration" do
      expect(described_class.with_defaults.call).to eq(configuration)
    end
  end

  describe "#call" do
    it "answers default configuration" do
      expect(loader.call).to eq(configuration)
    end
  end
end
