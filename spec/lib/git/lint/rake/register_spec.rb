# frozen_string_literal: true

require "git/lint/rake/register"
require "spec_helper"

RSpec.describe Git::Lint::Rake::Register do
  subject(:tasks) { described_class.new shell: }

  let(:shell) { instance_spy Git::Lint::CLI::Shell }

  before { Rake::Task.clear }

  describe ".setup" do
    it "installs rake tasks" do
      described_class.call
      expect(Rake::Task.tasks.map(&:name)).to contain_exactly("git_lint")
    end
  end

  describe "#call" do
    before { tasks.call }

    it "executes --analyze option via git_lint task" do
      Rake::Task["git_lint"].invoke
      expect(shell).to have_received(:call).with(["--analyze"])
    end
  end
end
