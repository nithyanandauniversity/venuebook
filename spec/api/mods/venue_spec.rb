require 'spec_helper'

describe 'Venue API' do
   it "should create venue" do
      post '/api/v1/venue', {name: "Yogam Center 1", center:1, country: 'Singapore', capacity: 56}

      resp = last_response.body

      resp= JSON.parse(resp)

      expect(resp["name"]).to eql "Yogam Center 1"

      expect(Venue.last.name).to eql resp["name"]
   end
end
