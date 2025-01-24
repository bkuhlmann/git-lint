# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Collector do
  subject(:collector) { described_class.new }

  let(:commit) { Gitt::Models::Commit.new }

  let :valid_analyzer do
    instance_spy Git::Lint::Analyzers::CommitSubjectPrefix,
                 class: Git::Lint::Analyzers::CommitSubjectPrefix,
                 commit:,
                 invalid?: false,
                 warning?: false,
                 error?: false
  end

  let :warn_analyzer do
    instance_spy Git::Lint::Analyzers::CommitSubjectPrefix,
                 class: Git::Lint::Analyzers::CommitSubjectPrefix,
                 commit:,
                 invalid?: true,
                 warning?: true,
                 error?: false
  end

  let :error_analyzer do
    instance_spy Git::Lint::Analyzers::CommitSubjectPrefix,
                 class: Git::Lint::Analyzers::CommitSubjectPrefix,
                 commit:,
                 invalid?: true,
                 warning?: false,
                 error?: true
  end

  let :group_analyzer do
    instance_spy Git::Lint::Analyzers::Commits::Subjects::Duplicate,
                 class: Git::Lint::Analyzers::Commits::Subjects::Duplicate,
                 commit: nil,
                 commits: %w[aaa bbb],
                 invalid?: true,
                 warning?: false,
                 error?: true
  end

  describe "#add" do
    it "adds analyzer" do
      collector.add valid_analyzer
      expect(collector.retrieve(commit)).to contain_exactly(valid_analyzer)
    end

    it "answers added analyzer" do
      expect(collector.add(valid_analyzer)).to eq(valid_analyzer)
    end
  end

  describe "#retrieve" do
    it "answers single analyzer for commit" do
      collector.add valid_analyzer
      expect(collector.retrieve(commit)).to contain_exactly(valid_analyzer)
    end

    it "answers multiple analyzers for commit" do
      collector.add valid_analyzer
      collector.add valid_analyzer

      expect(collector.retrieve(commit)).to contain_exactly(valid_analyzer, valid_analyzer)
    end
  end

  describe "#total" do
    it "answers total for individual analyzers" do
      collector.add valid_analyzer
      collector.add warn_analyzer
      collector.add error_analyzer

      expect(collector.total).to eq(
        Git::Lint::Models::Total[items: 1, issues: 2, warnings: 1, errors: 1]
      )
    end

    it "answers total group analyzers" do
      collector.add group_analyzer
      collector.add group_analyzer

      expect(collector.total).to eq(
        Git::Lint::Models::Total[items: 0, issues: 2, warnings: 0, errors: 2]
      )
    end
  end

  describe "#clear" do
    it "clears collection of all entries" do
      collector.add valid_analyzer
      collector.clear
      expect(collector.empty?).to be(true)
    end

    it "answers itself" do
      expect(collector.clear).to eq(collector)
    end
  end

  describe "#empty?" do
    it "answers true without data" do
      expect(collector.empty?).to be(true)
    end

    it "answers false with data" do
      collector.add valid_analyzer
      expect(collector.empty?).to be(false)
    end
  end

  describe "#to_h" do
    it "answers hash of commit and analyzers" do
      collector.add valid_analyzer
      expect(collector.to_h).to eq(commit => [valid_analyzer])
    end
  end
end
