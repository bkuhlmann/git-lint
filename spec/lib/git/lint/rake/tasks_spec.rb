# frozen_string_literal: true

require "spec_helper"
require "git/lint/rake/tasks"

RSpec.describe Git::Lint::Rake::Tasks do
  subject(:tasks) { described_class.new cli: cli }

  let(:cli) { class_spy Git::Lint::CLI }

  before { Rake::Task.clear }

  describe ".setup" do
    it "installs rake tasks" do
      described_class.setup
      expect(Rake::Task.tasks.map(&:name)).to contain_exactly("git_lint")
    end
  end

  describe "#install" do
    before { tasks.install }

    it "executes --analyze option via git_lint task" do
      Rake::Task["git_lint"].invoke
      expect(cli).to have_received(:start).with(["--analyze"])
    end
  end
end
