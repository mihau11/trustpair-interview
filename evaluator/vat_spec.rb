# frozen_string_literal: true
require File.join(File.dirname(__FILE__), "../spec_helper")

RSpec.describe Evaluator::Vat do
  describe "#call" do
    let(:stub_favorable) do
      stub_vat_evaluator_url(evaluation, { state: "favorable", reason: "company_opened" })
    end

    let(:stub_unfavorable) do
      stub_vat_evaluator_url(evaluation, { state: "unfavorable", reason: "company_closed" })
    end

    it_behaves_like "evaluator"
  end

  describe "instance methods" do
    let(:decrease_50_plus_value) { 1 }
    let(:decrease_49_minus_value) { 3 }

    it_behaves_like "evaluator's decreaser"
  end
end
