# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Branches::Environments::NetlifyCI do
  subject :branch do
    described_class.new repository: repository, shell: shell, environment: environment
  end

  let(:environment) { {"HEAD" => "test", "REPOSITORY_URL" => "https://www.example.com/test.git"} }
  let(:repository) { instance_spy GitPlus::Repository }
  let(:shell) { class_spy Open3 }

  describe "#name" do
    it "answers Git branch name" do
      expect(branch.name).to eq("test")
    end
  end

  describe "#commits" do
    it "adds remote origin branch" do
      branch.commits

      expect(shell).to have_received(:capture3).with(
        "git remote add -f origin https://www.example.com/test.git"
      )
    end

    it "fetches feature branch" do
      branch.commits
      expect(shell).to have_received(:capture3).with("git fetch origin test:test")
    end

    it "uses specific start and finish range" do
      branch.commits
      expect(repository).to have_received(:commits).with("origin/master..origin/test")
    end
  end
end
