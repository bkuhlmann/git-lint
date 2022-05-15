# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Configuration::Setting do
  subject(:content) { described_class.new }

  describe "#initialize" do
    let :proof do
      {
        delimiter: nil,
        enabled: nil,
        excludes: nil,
        id: nil,
        includes: nil,
        maximum: nil,
        minimum: nil,
        severity: nil
      }
    end

    it "answers default attributes" do
      expect(content).to have_attributes(proof)
    end

    it "fails when attempting to modify a frozen attribute" do
      expecation = proc { content.enabled = true }
      expect(&expecation).to raise_error(FrozenError)
    end
  end
end
