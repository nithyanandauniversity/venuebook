require 'rest_client'

class Participant < Sequel::Model
	self.plugin :timestamps
	one_to_many :event_attendances

	def self.create(params)
		response = RestClient.post PARBOOK_URL, params
		JSON.parse(response.body)
	end

	def self.search(params)
		response = RestClient.get PARBOOK_URL, {params: params}
		JSON.parse(response.body)
	end

	def self.update(id, params)
		response = RestClient.put PARBOOK_URL + "/#{id}", params
		JSON.parse(response.body)
	end

	def self.delete(id)
		response = RestClient.delete PARBOOK_URL + "/#{id}"
		JSON.parse(response)
	end

	def self.delete_all
		RestClient.delete PARBOOK_URL + '/delete_all'
	end
end
