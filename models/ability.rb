class Ability

	include CanCan::Ability

	def initialize(user)
		user ||= User.new

		if user['role'] <= 6
			can :manage, EventAttendance
			can :read, Participant, :center_id => user['center_id']
		end

		if user['role'] <= 5
			can :read, Event
			can [:create, :update], Participant, :center_id => user['center_id']
			can [:create, :update], EventVenue
		end

		if user['role'] <= 4
			can [:create, :update], Event
			can :read, Program, :center_id => user['center_id']
			can :read, [Participant, Center]
		end

		if user['role'] <= 3
			can :destroy, Event
			can :manage, [Venue, Address]

			can :read, Program, :center_id => nil
			can [:create, :read, :update, :destroy], Program do |project|
				center_id == user['center_id']
			end
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