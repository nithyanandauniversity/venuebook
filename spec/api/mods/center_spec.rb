require 'spec_helper'

describe "Center" do

   before(:all) do
      User.dataset.all { |u| u.destroy }
      user = User.create(first_name: "Saravana", last_name: "B", email: "sgsaravana@gmail.com", password: "123123", role: 1)

      post "/api/v1/sessions/login", auth: {
         email: "sgsaravana@gmail.com",
         password: "123123"
      }

      response = JSON.parse(last_response.body)
      @token   = response['token']
   end

   it "should be able to CRUD center" do

      post '/api/v1/center', {name:"Yogam Center", location: "Singapore", country: "Singapore"}, {'HTTP_TOKEN' => @token}

      resp = JSON.parse(last_response.body)

      expect(resp["name"]).to eql("Yogam Center")
      expect(resp["location"]).to eql("Singapore")
      expect(resp["country"]).to eql("Singapore")
   end

   it "should be able to edit center" do
      center = Center.create(name: "Yogam", location: "Singapore", country: "Singapore")

      put "/api/v1/center/#{center.id}", {center: {name: "Yogam Center"}}, {'HTTP_TOKEN' => @token}

      resp = JSON.parse(last_response.body)

      expect(resp["name"]).to eql("Yogam Center")
   end

   it "should be able to delete center" do
      center = Center.create(name: "Yogam", location: "Singapore", country: "Singapore")
      centerID = center.id

      delete "/api/v1/center/#{center.id}", nil, {'HTTP_TOKEN' => @token}

      expect(Center.find(id: center.id)).to eql nil
   end

end

