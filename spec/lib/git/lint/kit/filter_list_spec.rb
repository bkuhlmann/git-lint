# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Kit::FilterList do
  subject(:filter_list) { described_class.new list }

  describe "#to_hint" do
    context "with list" do
      let(:list) { ["one", "\\.", "\\Atest.+"] }

      it "answers list as string" do
        expect(filter_list.to_hint).to eq(%(/one/, /\\./, /\\Atest.+/))
      end
    end

    context "without list" do
      let(:list) { [] }

      it "answers list as empty string" do
        expect(filter_list.to_hint).to eq("")
      end
    end
  end

  describe "#to_regexp" do
    context "with list of strings" do
      let(:list) { %w[one two three] }

      it "answers regular expression array" do
        expect(filter_list.to_regexp).to contain_exactly(/one/, /two/, /three/)
      end
    end

    context "with list of regular expressions" do
      let(:list) { ["\\.", "\\Atest.+"] }

      it "answers regular expression array" do
        expect(filter_list.to_regexp).to contain_exactly(/\./, /\Atest.+/)
      end
    end

    context "without list" do
      let(:list) { [] }

      it "answers empty array" do
        expect(filter_list.to_regexp).to eq([])
      end
    end
  end

  describe "#empty?" do
    context "when empty" do
      let(:list) { [] }

      it "answers true" do
        expect(filter_list.empty?).to be(true)
      end
    end

    context "when not empty" do
      let(:list) { ["test"] }

      it "answers false" do
        expect(filter_list.empty?).to be(false)
      end
    end
  end
end
