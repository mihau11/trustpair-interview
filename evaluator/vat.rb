module Evaluator
  class Vat < Evaluator::Base
    def call
      parsed_response = evaluate_request

      @evaluation.state = parsed_response['state']
      @evaluation.reason = parsed_response['reason']
      @evaluation.score = 100
    end

    def api_url
      URI("https://vat-evaluator-api.com/?q=#{@evaluation.value}")
    end

    def decrease_50_plus
      1
    end

    def decrease_49_minus
      3
    end
  end
end
