module Evaluator
  class Siren < Evaluator::Base
    def call
      parsed_response = evaluate_request
      company_state = parsed_response["records"].first["fields"]["etatadministratifetablissement"]

      @evaluation.state = company_state == "Actif" ? "favorable" : "unfavorable"
      @evaluation.reason = company_state == "Actif" ? "company_opened" : "company_closed"
      @evaluation.score = 100
    end

    def api_url
      URI("https://public.opendatasoft.com/api/records/1.0/search/?dataset=sirene_v3" \
        "&q=#{@evaluation.value}&sort=datederniertraitementetablissement" \
        "&refine.etablissementsiege=oui")
    end

    def decrease_50_plus
      5
    end

    def decrease_49_minus
      1
    end
  end
end
