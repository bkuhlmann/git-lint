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
      analyze_shas: nil,
      analyzers: analyzers
    ]
  end

  let :analyzers do
    YAML.load_file(Bundler.root.join("lib/git/lint/configuration/defaults.yml"))[:analyzers]
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