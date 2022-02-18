require File.join(File.dirname(__FILE__), "trustin")
require "pry"
require "webmock"

include WebMock::API
WebMock.enable!

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
