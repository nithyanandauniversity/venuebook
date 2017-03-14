class Event < Sequel::Model
	self.plugin :timestamps
	one_to_many :event_venues
	many_to_many :venues, :left_key => :event_id, :right_key => :venue_id, :join_table => :event_venues
	many_to_many :users, :left_key => :event_id, :right_key => :user_id, :join_table => :event_venues
	many_to_one :program
end
