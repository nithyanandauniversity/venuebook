class Center < Sequel::Model
	self.plugin :timestamps
	one_to_many :venues
end
