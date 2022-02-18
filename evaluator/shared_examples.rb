shared_examples "evaluator" do
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

    before { stub_favorable }

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

      before { stub_unfavorable }

      it "does API request and assigns <state>, <reason> and <score>" do
        expect { subject }
          .to change { evaluation.state }.from("favorable").to("unfavorable")
          .and change { evaluation.reason }.from("any").to("company_closed")
          .and change { evaluation.score }.from(0).to(100)
      end
    end

    context "when <state> is unconfirmed" do
      let(:state) { "unconfirmed" }

      before { stub_unfavorable }

      it "does API request and assigns <state>, <reason> and <score>" do
        expect { subject }
          .to change { evaluation.state }.from("unconfirmed").to("unfavorable")
          .and change { evaluation.reason }.from("any").to("company_closed")
          .and change { evaluation.score }.from(0).to(100)
      end
    end
  end
end

shared_examples "evaluator's decreaser" do
  let(:evaluator) { described_class.new(double) }

  describe "#decrease_50_plus" do
    subject { evaluator.decrease_50_plus }

    it { is_expected.to eq(decrease_50_plus_value) }
  end

  describe "#decrease_49_minus" do
    subject { evaluator.decrease_49_minus }

    it { is_expected.to eq(decrease_49_minus_value) }
  end
end
