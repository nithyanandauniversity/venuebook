class Participant < Sequel::Model
	self.plugin :timestamps
	one_to_many :event_attendances

	def self.search(params)
		size = params[:limit].to_i || 10
		page = params[:page].to_i || 1
		keyword = params[:keyword] || nil

		if keyword
			# SEARCH
			Participant.where(
				"first_name LIKE ? OR last_name LIKE ? OR email LIKE ? OR other_names LIKE ?",
				"%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%"
				).paginate(page, size)
		else
			# ALL
			Participant.dataset.paginate(page, size)
		end
	end
end
