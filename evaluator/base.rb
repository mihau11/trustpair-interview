module Evaluator
  class Base
    attr_accessor :evaluation

    def initialize(evaluation)
      @evaluation = evaluation
    end

    def evaluate_request
      JSON.parse(Net::HTTP.get(api_url))
    end
  end
end
