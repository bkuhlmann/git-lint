# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Commits::Systems::GitHubAction do
  subject(:system) { described_class.new }

  include_context "with commit system dependencies"

  describe "#call" do
    it "uses specific start and finish range" do
      system.call
      expect(repository).to have_received(:commits).with("origin/main..origin/test")
    end
  end
end
