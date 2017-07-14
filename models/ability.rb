class Ability

	include CanCan::Ability

	def initialize(user)
		user ||= User.new

		if user['role'] <= 5
			can :manage, EventAttendance
			can :read, Event, :center_id => user['center_id']
			can :read, Participant, :center_id => user['center_id']
		end

		if user['role'] <= 4
			can [:create, :update], Event

			can [:create, :update], Participant, :center_id => user['center_id']

			can :manage, EventVenue
			can :read, User, :role => 4..5
			can :read, [Program, Participant, Center, Venue]
		end

		if user['role'] <= 3
			can :destroy, Event
			can :read, User, :role => 3..5
			can :manage, [Venue, Address]
		end

		if user['role'] <= 2
			can :update, Center
		end

		if user['role'] == 1
			can :destroy, Participant
			can :manage, [User, Center, Program]
		end
	end

end
