require 'spec_helper'

describe 'Venue API' do
   it "should create venue" do
      post '/api/v1/venue', {name: "Yogam Center 1", center:1, country: 'Singapore', capacity: 56}

      resp = JSON.parse(last_response.body)

      expect(resp["name"]).to eql "Yogam Center 1"
   end
end
