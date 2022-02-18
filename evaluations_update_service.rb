# frozen_string_literal: true

class EvaluationsUpdateService
  def initialize(evaluations)
    @evaluations = evaluations
  end

  def call
    @evaluations.each(&:update)
  end
end
