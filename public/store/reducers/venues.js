import { ADD_VENUE, EDIT_VENUE } from '../../constants/VenueActions'

export default function programs(state = {view: ADD_VENUE}, action) {
	switch (action.type) {
		case ADD_VENUE:
			return {
				view: ADD_VENUE
			}
		case EDIT_VENUE:
			return {
				view: EDIT_VENUE,
				id: action.id
			}
		default:
			return state;
	}
}