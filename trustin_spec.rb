# frozen_string_literal: true
require File.join(File.dirname(__FILE__), "spec_helper")

RSpec.describe TrustIn do
  describe "#update_score()" do
    let(:value) { "123456789" }
    let(:reason) { "any" }
    let(:evaluation) { Evaluation.new(type: type, value: value, score: score, state: state, reason: reason) }

    subject { described_class.new([evaluation]).update_score }

    shared_examples "unchanged evaluation" do
      let(:state) { "unfavorable" }
      let(:reason) { "company_closed" }

      it "does not decrease its <score>" do
        expect { subject }.not_to change { evaluation.score }
      end

      it "doesn't call API" do
        # no need to assert anything - Webmock simply raises an exception in case of unexpected request
      end
    end

    context "when <type> is 'SIREN'" do
      let(:type) { 'SIREN' }

      context "when <score> >= 50" do
        let(:score) { 50 }

        context "when <state> is unconfirmed" do
          let(:state) { "unconfirmed" }

          context "when <reason> is ongoing_database_update" do
            let(:value) { "832940670" }
            let(:reason) { "ongoing_database_update" }

            before { stub_company_state_url(value, 'Actif') }

            it "does API request and assigns <state>, <reason> and <score>" do
              expect { subject }
                .to change { evaluation.state }.from("unconfirmed").to("favorable")
                .and change { evaluation.reason }.from("ongoing_database_update").to("company_opened")
                .and change { evaluation.score }.from(50).to(100)
            end
          end

          context "when <reason> is unable_to_reach_api" do
            let(:reason) { "unable_to_reach_api" }

            it "decreases the <score> by 5" do
              expect { subject }.to change { evaluation.score }.by(-5)
            end
          end
        end

        context "when <state> is favorable" do
          let(:state) { "favorable" }

          it "decreases the <score> by 1" do
            expect { subject }.to change { evaluation.score }.by(-1)
          end
        end

        context "when <state> is unfavorable and <reason> is company_closed" do
          it_behaves_like "unchanged evaluation"
        end
      end

      context "when <score> is 1" do
        let(:score) { 1 }

        context "when <state> is unconfirmed" do
          let(:state) { "unconfirmed" }

          context "when <reason> is unable_to_reach_api" do
            let(:reason) { "unable_to_reach_api" }

            it "decreases the <score> by 1" do
              expect { subject }.to change { evaluation.score }.by(-1)
            end
          end
        end
      end

      context "when <score> is 0" do
        let(:score) { 0 }
        let(:value) { "320878499" }

        context "when <state> is favorable" do
          let(:state) { "favorable" }

          before { stub_company_state_url(value, "Ferm\u00e9") }

          it "does API request and assigns <state>, <reason> and <score>" do
            expect { subject }
              .to change { evaluation.state }.from("favorable").to("unfavorable")
              .and change { evaluation.reason }.from("any").to("company_closed")
              .and change { evaluation.score }.from(0).to(100)
          end
        end

        context "when <state> is unconfirmed" do
          let(:state) { "unconfirmed" }

          before { stub_company_state_url(value, "Ferm\u00e9") }

          it "does API request and assigns <state>, <reason> and <score>" do
            expect { subject }
              .to change { evaluation.state }.from("unconfirmed").to("unfavorable")
              .and change { evaluation.reason }.from("any").to("company_closed")
              .and change { evaluation.score }.from(0).to(100)
          end
        end

        context "when <state> is unfavorable and <reason> is company_closed" do
          it_behaves_like "unchanged evaluation"
        end

      end
    end
  end
end

