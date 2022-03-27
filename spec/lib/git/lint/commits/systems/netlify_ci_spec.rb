# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Commits::Systems::NetlifyCI do
  subject(:system) { described_class.new }

  include_context "with commit system dependencies"

  let(:environment) { {"HEAD" => "test", "REPOSITORY_URL" => "https://www.example.com/test.git"} }

  describe "#call" do
    it "adds remote origin branch" do
      system.call

      expect(executor).to have_received(:capture3).with(
        "git remote add -f origin https://www.example.com/test.git"
      )
    end

    it "fetches feature branch" do
      system.call
      expect(executor).to have_received(:capture3).with("git fetch origin test:test")
    end

    it "uses specific start and finish range" do
      system.call
      expect(repository).to have_received(:commits).with("origin/main..origin/test")
    end
  end
end
