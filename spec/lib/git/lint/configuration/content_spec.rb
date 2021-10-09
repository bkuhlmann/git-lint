# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Configuration::Content do
  subject(:content) { described_class.new }

  describe "#initialize" do
    let :proof do
      {
        action_analyze: nil,
        action_config: nil,
        action_help: nil,
        action_hook: nil,
        action_version: nil,
        analyze_shas: nil,
        analyzers: nil
      }
    end

    it "answers default attributes" do
      expect(content).to have_attributes(proof)
    end

    it "fails when attempting to modify a frozen attribute" do
      expecation = proc { content.action_help = "danger" }
      expect(&expecation).to raise_error(FrozenError)
    end
  end
end
