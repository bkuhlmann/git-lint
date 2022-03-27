# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::Abstract do
  subject(:analyzer) { described_class.new git_commit }

  include_context "with application dependencies"
  include_context "with Git commit"

  let :configuration do
    Git::Lint::Configuration::Content[
      analyzers: [Git::Lint::Configuration::Setting[id: :abstract, enabled: true, severity: :error]]
    ]
  end

  let :valid_analyzer do
    Class.new described_class do
      def self.id = :abtract

      def valid? = true
    end
  end

  let :invalid_analyzer do
    Class.new described_class do
      def self.id = :abstract

      def valid? = false
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

  describe ".build_issue_line" do
    it "answers isuse line" do
      expect(described_class.build_issue_line(1, "Test.")).to eq(number: 3, content: "Test.")
    end
  end

  describe "#enabled?" do
    it "answers true when enabled" do
      expect(analyzer.enabled?).to be(true)
    end

    context "when disabled" do
      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [Git::Lint::Configuration::Setting[id: :abstract, enabled: false]]
        ]
      end

      it "answers false" do
        expect(analyzer.enabled?).to be(false)
      end
    end
  end

  describe "#severity" do
    it "answers severity when severity is defined" do
      expect(analyzer.severity).to eq(:error)
    end

    context "without severity" do
      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [Git::Lint::Configuration::Setting[id: :abstract]]
        ]
      end

      it "fails with severity error" do
        result = -> { analyzer.severity }
        expect(&result).to raise_error(Git::Lint::Errors::Severity, /invalid severity/i)
      end
    end

    context "with invalid severity" do
      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [Git::Lint::Configuration::Setting[id: :abstract, severity: :bogus]]
        ]
      end

      it "fails with invalid severity error" do
        result = -> { analyzer.severity }
        expect(&result).to raise_error(Git::Lint::Errors::Severity, /invalid severity.+bogus/i)
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
      expect(invalid_analyzer.new(git_commit).invalid?).to be(true)
    end

    it "answers false when valid" do
      expect(valid_analyzer.new(git_commit).invalid?).to be(false)
    end

    it "fails with NotImplementedError when not implemented" do
      result = -> { analyzer.invalid? }
      expect(&result).to raise_error(NotImplementedError, /.+\#valid\?.+/)
    end
  end

  describe "#warning?" do
    let :configuration do
      Git::Lint::Configuration::Content[
        analyzers: [
          Git::Lint::Configuration::Setting[id: :abstract, enabled: true, severity: :warn]
        ]
      ]
    end

    it "answers true when invalid" do
      expect(invalid_analyzer.new(git_commit).warning?).to be(true)
    end

    it "answers false when valid" do
      expect(valid_analyzer.new(git_commit).warning?).to be(false)
    end

    it "fails with NotImplementedError when not implemented" do
      result = -> { analyzer.warning? }
      expect(&result).to raise_error(NotImplementedError, /.+\#valid\?.+/)
    end
  end

  describe "#error?" do
    it "answers true when invalid" do
      expect(invalid_analyzer.new(git_commit).error?).to be(true)
    end

    it "answers false when valid" do
      expect(valid_analyzer.new(git_commit).error?).to be(false)
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
