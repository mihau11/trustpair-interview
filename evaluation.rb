# frozen_string_literal: true

class Evaluation
  attr_accessor :type, :value, :score, :state, :reason

  def initialize(type:, value:, score:, state:, reason:)
    @type = type
    @value = value
    @score = score
    @state = state
    @reason = reason
  end

  def self.company_state_url(q)
    URI("https://public.opendatasoft.com/api/records/1.0/search/?dataset=sirene_v3" \
      "&q=#{q}&sort=datederniertraitementetablissement" \
      "&refine.etablissementsiege=oui")
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
    uri = Evaluation.company_state_url(@value)
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)
    parsed_response["records"].first["fields"]["etatadministratifetablissement"]
  end

  def evaluate
    if @type == "SIREN"
      company_state = company_state_request

      @state = company_state == "Actif" ? "favorable" : "unfavorable"
      @reason = company_state == "Actif" ? "company_opened" : "company_closed"
      @score = 100
    else
      raise "unsupported type"
    end
  end

  def update
    if with_score?
      if unconfirmed_ongoing?
        evaluate
      elsif unconfirmed_unreachable?
        score >= 50 ? decrease_score_by(5) : decrease_score_by(1)
      elsif favorable?
        decrease_score_by(1)
      end
    elsif unconfirmed_or_favorable?
      evaluate
    else
      # log: evaluation was not updated => evaluation.attributes.to_s
      # to catche cases we don't update
    end
  end
end
