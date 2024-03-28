# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Commits::Hosts::Local do
  subject(:host) { described_class.new git: }

  include_context "with host dependencies"

  describe "#call" do
    it "uses specific start and finish range" do
      host.call
      expect(git).to have_received(:commits).with("main..test")
    end
  end
end
