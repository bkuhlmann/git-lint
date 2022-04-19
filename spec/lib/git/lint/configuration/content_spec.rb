# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Configuration::Content do
  subject(:content) { described_class[analyzers: [setting]] }

  let(:setting) { Git::Lint::Configuration::Setting[id: :commit_subject_prefix, enabled: true] }

  describe "#initialize" do
    let :proof do
      {
        action_analyze: nil,
        action_config: nil,
        action_help: nil,
        action_hook: nil,
        action_version: nil,
        analyze_sha: nil,
        analyzers: nil
      }
    end

    it "answers default attributes" do
      expect(described_class.new).to have_attributes(proof)
    end

    it "fails when attempting to modify a frozen attribute" do
      expecation = proc { described_class.new.action_help = "danger" }
      expect(&expecation).to raise_error(FrozenError)
    end
  end

  describe "#find_setting" do
    it "answers setting by ID" do
      expect(content.find_setting(:commit_subject_prefix)).to eq(setting)
    end

    it "answers nil when ID isn't found" do
      expect(content.find_setting(:mystery)).to be(nil)
    end
  end
end
