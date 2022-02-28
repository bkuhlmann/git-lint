# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Collector do
  subject(:collector) { described_class.new }

  let(:commit) { GitPlus::Commit.new }

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

  describe "#warnings?" do
    it "answers true with invalid analyzers at warn severity" do
      collector.add valid_analyzer
      collector.add warn_analyzer
      collector.add error_analyzer

      expect(collector.warnings?).to be(true)
    end

    it "answers false with no invalid analyzers at warn severity" do
      collector.add valid_analyzer
      collector.add error_analyzer

      expect(collector.warnings?).to be(false)
    end
  end

  describe "#errors?" do
    it "answers true with invalid analyzers at error severity" do
      collector.add valid_analyzer
      collector.add warn_analyzer
      collector.add error_analyzer

      expect(collector.errors?).to be(true)
    end

    it "answers false with no invalid analyzers at error severity" do
      collector.add valid_analyzer
      collector.add warn_analyzer

      expect(collector.errors?).to be(false)
    end
  end

  describe "#issues?" do
    it "answers true with invalid analyzers" do
      collector.add valid_analyzer
      collector.add warn_analyzer
      collector.add error_analyzer

      expect(collector.issues?).to be(true)
    end

    it "answers false with valid analyzers" do
      collector.add valid_analyzer
      expect(collector.issues?).to be(false)
    end
  end

  describe "#total_warnings" do
    it "answers total warnings when invalid analyzers with warnings exist" do
      collector.add warn_analyzer
      expect(collector.total_warnings).to eq(1)
    end

    it "answers zero warnings when analyzers without warnings exist" do
      collector.add valid_analyzer
      collector.add error_analyzer

      expect(collector.total_warnings).to eq(0)
    end
  end

  describe "#total_errors" do
    it "answers total errors when invalid analyzers with errors exist" do
      collector.add error_analyzer
      expect(collector.total_errors).to eq(1)
    end

    it "answers zero errors when analyzers without errors exist" do
      collector.add valid_analyzer
      collector.add warn_analyzer

      expect(collector.total_errors).to eq(0)
    end
  end

  describe "#total_issues" do
    it "answers total issues when invalid analyzers exist" do
      collector.add valid_analyzer
      collector.add warn_analyzer
      collector.add error_analyzer

      expect(collector.total_issues).to eq(2)
    end

    it "answers zero issues when valid analyzers exist" do
      collector.add valid_analyzer
      expect(collector.total_issues).to eq(0)
    end

    it "answers zero issues when no analyzers exist" do
      expect(collector.total_issues).to eq(0)
    end
  end

  describe "#total_commits" do
    it "answers total commits" do
      collector.add valid_analyzer
      expect(collector.total_commits).to eq(1)
    end

    it "answers zero with no commits" do
      expect(collector.total_commits).to eq(0)
    end
  end

  describe "#to_h" do
    it "answers hash of commit and analyzers" do
      collector.add valid_analyzer
      expect(collector.to_h).to eq(commit => [valid_analyzer])
    end
  end
end
