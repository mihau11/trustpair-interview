# frozen_string_literal: true

require "json"
require "net/http"
require "pry"
require "webmock"

require File.join(File.dirname(__FILE__), "evaluation")
require File.join(File.dirname(__FILE__), "evaluations_update_command")
Dir[File.join(__dir__, "evaluator", "*.rb")].each { |file| require file }

#
# kind of config piece
#
include WebMock::API
WebMock.enable!

#
# spec helpers
#
def stub_evaluator_url(evaluation, status)
  stub_request(:get, evaluation.evaluator.api_url).
    with(
      headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Host'=>'public.opendatasoft.com',
        'User-Agent'=>'Ruby'
      }
    ).to_return(status: 200, headers: {}, body: { "records": [{ "fields": { "etatadministratifetablissement": status } }] }.to_json)
end
