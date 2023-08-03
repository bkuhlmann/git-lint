# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Kit::FilterList do
  subject(:filter_list) { described_class.new list }

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

  shared_context "with array" do |method|
    context "with list of strings" do
      let(:list) { %w[one two three] }

      it "answers regular expression array" do
        expect(filter_list.public_send(method)).to contain_exactly(/one/, /two/, /three/)
      end
    end

    context "with list of regular expressions" do
      let(:list) { ["\\.", "\\Atest.+"] }

      it "answers regular expression array" do
        expect(filter_list.public_send(method)).to contain_exactly(/\./, /\Atest.+/)
      end
    end

    context "without list" do
      let(:list) { [] }

      it "answers empty array" do
        expect(filter_list.public_send(method)).to eq([])
      end
    end
  end

  describe "#to_a" do
    it_behaves_like "with array", :to_a
  end

  describe "#to_ary" do
    it_behaves_like "with array", :to_ary
  end

  describe "#to_usage" do
    context "with list" do
      let(:list) { ["one", "\\.", "\\Atest.+"] }

      it "answers list as string" do
        expect(filter_list.to_usage).to eq(%(/one/, /\\./, and /\\Atest.+/))
      end
    end

    context "without list" do
      let(:list) { [] }

      it "answers list as empty string" do
        expect(filter_list.to_usage).to eq("")
      end
    end
  end
end
