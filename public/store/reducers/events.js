import { ADD_EVENT, VIEW_EVENT, EDIT_EVENT, UPCOMING_EVENT, PAST_EVENT, SEARCH_EVENT } from '../../constants/EventActions'

export default function events(state = {view: UPCOMING_EVENT}, action) {
	switch (action.type) {
		case ADD_EVENT:
			return {
				view   : ADD_EVENT,
				params : action.params
			}
		case VIEW_EVENT:
			return {
				view : VIEW_EVENT,
				id   : action.id
			}
		case EDIT_EVENT:
			return {
				view : EDIT_EVENT,
				id   : action.id
			}
		case UPCOMING_EVENT:
			return {
				view : UPCOMING_EVENT
			}
		case PAST_EVENT:
			return {
				view : PAST_EVENT
			}
		case SEARCH_EVENT:
			return {
				view  : SEARCH_EVENT,
				query : action.query
			}
		default:
			return state;
	}
}

