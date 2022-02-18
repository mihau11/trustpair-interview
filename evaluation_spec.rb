# frozen_string_literal: true
require File.join(File.dirname(__FILE__), "spec_helper")

RSpec.describe Evaluation do
  describe "#update" do
    let(:value) { "123456789" }
    let(:reason) { "any" }
    let(:evaluator) { double }
    let(:evaluator_klass) { double(new: evaluator)}
    let(:evaluation) { described_class.new(evaluator: evaluator_klass, value: value, score: score, state: state, reason: reason) }

    subject { evaluation.update }

    shared_examples "evaluated evaluation" do
      it "calls evaluator (API request)" do
        expect(evaluator).to receive(:call)
        subject
      end
    end

    shared_examples "unchanged evaluation" do
      let(:state) { "unfavorable" }
      let(:reason) { "company_closed" }

      it "does not decrease its <score>" do
        expect { subject }.not_to change { evaluation.score }
      end

      it "doesn't call API" do
        expect(evaluator).not_to receive(:call)
      end
    end

    context "when <score> >= 50" do
      let(:score) { 50 }

      context "when <state> is unconfirmed" do
        let(:state) { "unconfirmed" }

        context "when <reason> is ongoing_database_update" do
          let(:value) { "832940670" }
          let(:reason) { "ongoing_database_update" }

          it_behaves_like "evaluated evaluation"
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

        it_behaves_like "evaluated evaluation"
      end

      context "when <state> is unconfirmed" do
        let(:state) { "unconfirmed" }

        it_behaves_like "evaluated evaluation"
      end

      context "when <state> is unfavorable and <reason> is company_closed" do
        it_behaves_like "unchanged evaluation"
      end
    end
  end
end
