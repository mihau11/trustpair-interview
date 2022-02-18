# frozen_string_literal: true
require File.join(File.dirname(__FILE__), "../spec_helper")

RSpec.describe Evaluator::Siren do
  describe "#call" do
    let(:stub_favorable) { stub_siren_evaluator_url(evaluation, "Actif") }
    let(:stub_unfavorable) { stub_siren_evaluator_url(evaluation, "Ferm\u00e9") }

    it_behaves_like "evaluator"
  end
end
