# frozen_string_literal: true

require "json"
require "net/http"
require "pry"
require "webmock"

require File.join(File.dirname(__FILE__), "evaluation")
require File.join(File.dirname(__FILE__), "evaluations_update_service")

#
# kind of config piece
#
include WebMock::API
WebMock.enable!

#
# spec helpers
#
def stub_company_state_url(q, status)
  stub_request(:get, Evaluation.company_state_url(q)).
    with(
      headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Host'=>'public.opendatasoft.com',
        'User-Agent'=>'Ruby'
      }
    ).to_return(status: 200, headers: {}, body: { "records": [{ "fields": { "etatadministratifetablissement": status } }] }.to_json)
end
