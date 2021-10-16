# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::Abstract do
  subject(:analyzer) { described_class.new commit: git_commit, settings: settings }

  include_context "with Git commit"

  let(:settings) { {enabled: true} }

  let :valid_analyzer do
    Class.new described_class do
      def valid?
        true
      end
    end
  end

  let :invalid_analyzer do
    Class.new described_class do
      def valid?
        false
      end
    end
  end

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:abstract)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Abstract")
    end
  end

  describe ".defaults" do
    it "fails with NotImplementedError" do
      result = -> { described_class.defaults }
      expect(&result).to raise_error(NotImplementedError, /.+\.defaults.+/)
    end
  end

  describe ".build_issue_line" do
    it "answers isuse line" do
      expect(described_class.build_issue_line(1, "Test.")).to eq(number: 3, content: "Test.")
    end
  end

  describe "#enabled?" do
    context "when enabled" do
      let(:settings) { {enabled: true} }

      it "answers true" do
        expect(analyzer.enabled?).to eq(true)
      end
    end

    context "when disabled" do
      let(:settings) { {enabled: false} }

      it "answers false" do
        expect(analyzer.enabled?).to eq(false)
      end
    end
  end

  describe "#severity" do
    context "with severity" do
      let(:settings) { {severity: :error} }

      it "answers severity" do
        expect(analyzer.severity).to eq(:error)
      end
    end

    context "without severity" do
      let(:settings) { Hash.new }

      it "fails with key error" do
        result = -> { analyzer.severity }
        expect(&result).to raise_error(KeyError)
      end
    end

    context "with invalid severity" do
      let(:settings) { {severity: :bogus} }

      it "fails with invalid severity error" do
        result = -> { analyzer.severity }
        expect(&result).to raise_error(Git::Lint::Errors::Severity)
      end
    end
  end

  describe "#valid?" do
    it "fails with NotImplementedError" do
      result = -> { analyzer.valid? }
      expect(&result).to raise_error(NotImplementedError, /.+\#valid\?.+/)
    end
  end

  describe "#invalid?" do
    it "answers true when not valid" do
      expect(invalid_analyzer.new(commit: git_commit, settings: settings).invalid?).to eq(true)
    end

    it "answers false when valid" do
      expect(valid_analyzer.new(commit: git_commit, settings: settings).invalid?).to eq(false)
    end

    it "fails with NotImplementedError when not implemented" do
      result = -> { analyzer.invalid? }
      expect(&result).to raise_error(NotImplementedError, /.+\#valid\?.+/)
    end
  end

  describe "#warning?" do
    let(:settings) { {enabled: true, severity: :warn} }

    it "answers true when invalid" do
      expect(invalid_analyzer.new(commit: git_commit, settings: settings).warning?).to eq(true)
    end

    it "answers false when valid" do
      expect(valid_analyzer.new(commit: git_commit, settings: settings).warning?).to eq(false)
    end

    it "fails with NotImplementedError when not implemented" do
      result = -> { analyzer.warning? }
      expect(&result).to raise_error(NotImplementedError, /.+\#valid\?.+/)
    end
  end

  describe "#error?" do
    let(:settings) { {enabled: true, severity: :error} }

    it "answers true when invalid" do
      expect(invalid_analyzer.new(commit: git_commit, settings: settings).error?).to eq(true)
    end

    it "answers false when valid" do
      expect(valid_analyzer.new(commit: git_commit, settings: settings).error?).to eq(false)
    end

    it "fails with NotImplementedError when not implemented" do
      result = -> { analyzer.error? }
      expect(&result).to raise_error(NotImplementedError, /.+\#valid\?.+/)
    end
  end

  describe "#issue" do
    it "fails with NotImplementedError" do
      result = -> { analyzer.issue }
      expect(&result).to raise_error(NotImplementedError, /.+\#issue.+/)
    end
  end
end
