require 'rest_client'

class Participant < Sequel::Model
	self.plugin :timestamps
	one_to_many :event_attendances

	def self.search(params)
		response = RestClient.get PARBOOK_URL, {params: params}
		JSON.parse(response.body)
	end

	def self.get(id)
		response = RestClient.get PARBOOK_URL + "/#{id}"
		JSON.parse(response.body)
	end

	def self.create(params)
		response = RestClient.post PARBOOK_URL, params
		JSON.parse(response.body)
	end

	def self.update(id, params)
		response = RestClient.put PARBOOK_URL + "/#{id}", params
		JSON.parse(response.body)
	end

	def self.deleteContact(id, contact_id)
		response = RestClient.delete PARBOOK_URL + "/#{id}/contact/#{contact_id}"
		JSON.parse(response)
	end

	def self.deleteAddress(id, address_id)
		response = RestClient.delete PARBOOK_URL + "/#{id}/address/#{address_id}"
		JSON.parse(response)
	end

	def self.delete(id)
		RestClient.delete PARBOOK_URL + "/#{id}"
	end

	def self.delete_all
		RestClient.delete PARBOOK_URL + '/delete_all'
	end
end
