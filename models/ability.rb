class Ability

	include CanCan::Ability

	def initialize(user)
		user ||= User.new

		if user['role'] <= 6
			can :manage, EventAttendance
			can :read, Participant, :center_id => user['center_id']
		end

		if user['role'] <= 5
			can [:create, :update], Participant, :center_id => user['center_id']
			can [:create, :update], EventVenue
		end

		if user['role'] <= 4
			can [:create, :update], Event
			can :read, Participant
		end

		if user['role'] <= 3
			can :manage, Venue
			can :manage, Address
			# can :manage, Program
		end

		if user['role'] <= 2
			can :read, Center
		end

		if user['role'] == 1
			can :destroy, Participant
			can :manage, User
			can :manage, Center
		end
	end

end