# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Commits::Hosts::NetlifyCI do
  subject(:host) { described_class.new git:, environment: }

  include_context "with host dependencies"

  let(:environment) { {"HEAD" => "test", "REPOSITORY_URL" => "https://www.example.com/test.git"} }

  describe "#call" do
    it "adds remote origin branch" do
      host.call

      expect(git).to have_received(:call).with(
        "remote", "add", "-f", "origin", "https://www.example.com/test.git"
      )
    end

    it "fetches feature branch" do
      host.call
      expect(git).to have_received(:call).with("fetch", "origin", "test:test")
    end

    it "uses specific start and finish range" do
      host.call
      expect(git).to have_received(:commits).with("origin/main..origin/test")
    end
  end
end
