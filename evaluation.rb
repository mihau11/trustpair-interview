# frozen_string_literal: true

class Evaluation
  attr_accessor :evaluator, :value, :score, :state, :reason

  def initialize(evaluator:, value:, score:, state:, reason:)
    @evaluator = evaluator.new(self)
    @value = value
    @score = score
    @state = state
    @reason = reason
  end

  def decrease_score_by(val)
    @score -= val
    @score = 0 if @score < 0
    @score
  end

  def favorable?
    @state == "favorable"
  end

  def unconfirmed_unreachable?
    @state == "unconfirmed" && @reason == "unable_to_reach_api"
  end

  def unconfirmed_ongoing?
    @state == "unconfirmed" && @reason == "ongoing_database_update"
  end

  def with_score?
    @score > 0
  end

  def unconfirmed_or_favorable?
    %w(favorable unconfirmed).include?(@state)
  end

  def update
    if with_score?
      if unconfirmed_ongoing?
        evaluator.call
      elsif unconfirmed_unreachable?
        decrease_by = score >= 50 ? evaluator.decrease_50_plus : evaluator.decrease_49_minus
        decrease_score_by(decrease_by)
      elsif favorable?
        decrease_score_by(1)
      else
        # log: evaluation was not updated => evaluation.attributes.to_s
        # to catch cases we didn't update
      end
    elsif unconfirmed_or_favorable?
      evaluator.call
    else
      # log: evaluation was not updated => evaluation.attributes.to_s
      # to catch cases we didn't update
    end
  end
end
