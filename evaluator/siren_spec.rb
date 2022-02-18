# frozen_string_literal: true
require File.join(File.dirname(__FILE__), "../spec_helper")

RSpec.describe Evaluator::Siren do
  describe "#call" do
    subject { described_class.new(evaluation).call }

    context "when <score> is 50 AND <state> is unconfirmed AND <reason> is ongoing_database_update" do
      let(:evaluation) do
        Evaluation.new(
          evaluator: described_class,
          value: "832940670",
          score: 50,
          state: "unconfirmed",
          reason: "ongoing_database_update"
        )
      end

      before { stub_siren_evaluator_url(evaluation, "Actif") }

      it "does API request and assigns <state>, <reason> and <score>" do
        expect { subject }
        .to change { evaluation.state }.from("unconfirmed").to("favorable")
        .and change { evaluation.reason }.from("ongoing_database_update").to("company_opened")
        .and change { evaluation.score }.from(50).to(100)
      end
    end

    context "when <score> is 0" do
      let(:evaluation) do
        Evaluation.new(
          evaluator: described_class,
          value: "320878499",
          score: 0,
          state: state,
          reason: "any"
        )
      end

      context "when <state> is favorable" do
        let(:state) { "favorable" }

        before { stub_siren_evaluator_url(evaluation, "Ferm\u00e9") }

        it "does API request and assigns <state>, <reason> and <score>" do
          expect { subject }
            .to change { evaluation.state }.from("favorable").to("unfavorable")
            .and change { evaluation.reason }.from("any").to("company_closed")
            .and change { evaluation.score }.from(0).to(100)
        end
      end

      context "when <state> is unconfirmed" do
        let(:state) { "unconfirmed" }

        before { stub_siren_evaluator_url(evaluation, "Ferm\u00e9") }

        it "does API request and assigns <state>, <reason> and <score>" do
          expect { subject }
            .to change { evaluation.state }.from("unconfirmed").to("unfavorable")
            .and change { evaluation.reason }.from("any").to("company_closed")
            .and change { evaluation.score }.from(0).to(100)
        end
      end
    end
  end
end
