require 'spec_helper'

describe "Center" do

   it "should be able to CRUD center" do

      post '/api/v1/center', {name:"Yogam Center", location: "Singapore"}

      resp = JSON.parse(last_response.body)

      expect(resp["name"]).to eql("Yogam Center")
   end

   it "should be able to add address" do

      center = Center.create(name: "Yogam", location: "Singapore")
      post "/api/v1/center/#{center.id}/address", address: {address:"11 Street", city:"Singapore", country: "Singapore"}

      resp = JSON.parse(last_response.body)

      expect(resp["address"]).to eql "11 Street"

      expect(Address.find(id:resp["id"]).center[:name]).to eql "Yogam"
   end

   it "should be able to edit center" do
      center = Center.create(name: "Yogam", location: "Singapore")

      put "/api/v1/center/#{center.id}", center: {name: "Yogam Center"}

      resp = JSON.parse(last_response.body)

      expect(resp["name"]).to eql("Yogam Center")
   end

   it "should be able to edit center address" do

      center = Center.create(name: "Yogam", location: "Singapore")
      post "/api/v1/center/#{center.id}/address", address: {address:"11 Street", city:"Singapore", country: "Singapore"}

      address = JSON.parse(last_response.body)

      put "/api/v1/center/#{center.id}/address/#{address['id']}", address: {address: "411 Race course Road"}

      response = JSON.parse(last_response.body)

      expect(response["address"]).to eql "411 Race course Road"
      expect(response["city"]).to eql "Singapore"

      expect(Address.find(id:response["id"]).center[:name]).to eql "Yogam"
   end
      
end

