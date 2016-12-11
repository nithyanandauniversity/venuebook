require 'spec_helper'

describe "Events" do
   it "should be able to CRUD events" do
      venue = Venue.create(name: "Yogam")
      post '/api/v1/event', event: {venue:venue[:id], start_date: Date.today, end_date: Date.tomorrow}

      res = JSON.parse(last_response.body)
      p res
      expet(Event.find(id:res[:id]).venue["name"]).to eql "Yogam"
   end
end
      
