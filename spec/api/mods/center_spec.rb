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

   it "should be able to create center with an administrator" do

      post '/api/v1/centers', {
         center: {name:"Yogam Center", state: "Singapore", country: "Singapore"},
         admin: {first_name: "Saravana", email: "saravana@gmail.com", password: "123111"}
      }, {'HTTP_TOKEN' => @token}

      resp = JSON.parse(last_response.body)

      center = Center.find(id: resp['id'])

      expect(resp["name"]).to eql("Yogam Center")
      expect(resp["state"]).to eql("Singapore")
      expect(resp["country"]).to eql("Singapore")
      expect(resp["code"]).not_to eql nil

      expect(center.admin).not_to eql nil
      expect(center.admin[:first_name]).to eql "Saravana"
      expect(center.admin[:email]).to eql "saravana@gmail.com"
   end

   it "should be able to get center by id" do

      post '/api/v1/centers', {
         center: {name:"Yogam Center", state: "Singapore", country: "Singapore"},
         admin: {first_name: "Saravana", email: "saravana@gmail.com", password: "123111"}
      }, {'HTTP_TOKEN' => @token}

      res = JSON.parse(last_response.body)

      get "/api/v1/centers/#{res['id']}", nil, {'HTTP_TOKEN' => @token}

      response = JSON.parse(last_response.body)

      expect(response['center']['name']).to eql "Yogam Center"
      expect(response['admin']['email']).to eql "saravana@gmail.com"
   end

   it "should be able to list all centers" do
      Center.dataset.all { |c| c.destroy }
      center1 = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
      center2 = Center.create(name: "San Jose Adheenam", state: "California", country: "USA")
      center2 = Center.create(name: "Bidadi Aadheenam", state: "Karnataka", country: "India")

      get "/api/v1/centers", nil, {'HTTP_TOKEN' => @token}

      response = JSON.parse(last_response.body)

      expect(response[0]['centers'].length).to eql 3
   end

   it "should be able to search center by name" do
      Center.dataset.all { |c| c.destroy }
      center1 = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
      center2 = Center.create(name: "San Jose Adheenam", state: "California", country: "USA")

      get "/api/v1/centers", {search: {
         page: 1,
         limit: 10,
         keyword: "Yogam"
      }}, {'HTTP_TOKEN' => @token}

      response = JSON.parse(last_response.body)[0]['centers']

      expect(response.length).to eql 1
   end

   it "should be able to edit center" do
      post '/api/v1/centers', {
         center: {name:"Yogam", state: "Singapore", country: "Singapore"},
         admin: {first_name: "Saravana", email: "saravana@gmail.com", password: "123111"}
      }, {'HTTP_TOKEN' => @token}

      res    = JSON.parse(last_response.body)
      center = Center.find(id: res['id'])

      put "/api/v1/centers/#{center.id}", {
         center: {name: "Yogam Center"},
         admin: {last_name: "B"}
      }, {'HTTP_TOKEN' => @token}

      resp = JSON.parse(last_response.body)

      expect(resp['center']["name"]).to eql "Yogam Center"
      expect(resp['admin']['last_name']).to eql "B"
   end

   it "should be able to delete center" do
      center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
      centerID = center.id

      delete "/api/v1/centers/#{center.id}", nil, {'HTTP_TOKEN' => @token}

      expect(Center.find(id: center.id)).to eql nil
   end

end

