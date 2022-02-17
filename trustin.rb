require "json"
require "net/http"

class TrustIn
  def initialize(evaluations)
    @evaluations = evaluations
  end

  def update_score()
    @evaluations.each do |evaluation|
      if evaluation.type == "SIREN"
        if evaluation.with_score?
          if evaluation.unconfirmed_ongoing?
            evaluation.evaluate
          elsif evaluation.unconfirmed_unreachable?
            evaluation.score >= 50 ? evaluation.decrease_score_by(5) : evaluation.decrease_score_by(1)
          elsif evaluation.favorable?
            evaluation.decrease_score_by(1)
          end
        elsif evaluation.unconfirmed_or_favorable?
          evaluation.evaluate
        end
      end
    end
  end
end

class Evaluation
  attr_accessor :type, :value, :score, :state, :reason

  def initialize(type:, value:, score:, state:, reason:)
    @type = type
    @value = value
    @score = score
    @state = state
    @reason = reason
  end

  def decrease_score_by(val)
    @score -= val
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

  def company_state_request
    uri = URI("https://public.opendatasoft.com/api/records/1.0/search/?dataset=sirene_v3" \
      "&q=#{@value}&sort=datederniertraitementetablissement" \
      "&refine.etablissementsiege=oui")
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)
    parsed_response["records"].first["fields"]["etatadministratifetablissement"]
  end

  def evaluate
    company_state = company_state_request

    if company_state == "Actif"
      @state = "favorable"
      @reason = "company_opened"
      @score = 100
    else
      @state = "unfavorable"
      @reason = "company_closed"
      @score = 100
    end
  end
end
