import { LIST_PARTICIPANT, ADD_PARTICIPANT, VIEW_PARTICIPANT, EDIT_PARTICIPANT, SEARCH_PARTICIPANT, MERGE_PARTICIPANT, DELETE_PARTICIPANT } from '../../constants/ParticipantActions'

export default function participants(state = {view: LIST_PARTICIPANT, page: 1}, action) {
	switch (action.type) {
		case LIST_PARTICIPANT:
			return {
				view  : LIST_PARTICIPANT,
				page  : action.page,
				query : action.query
			}
		case ADD_PARTICIPANT:
			return {
				view : ADD_PARTICIPANT
			}
		case VIEW_PARTICIPANT:
			return {
				view : VIEW_PARTICIPANT,
				id   : action.id
			}
		case EDIT_PARTICIPANT:
			return {
				view : EDIT_PARTICIPANT,
				id   : action.id
			}
		case SEARCH_PARTICIPANT:
			return	{
				view  : SEARCH_PARTICIPANT,
				query : action.query
			}
		case MERGE_PARTICIPANT:
			return	{
				view : MERGE_PARTICIPANT,
				step : action.step,
				data : action.data
			}
		case DELETE_PARTICIPANT:
			return {
				view : DELETE_PARTICIPANT,
				id   : action.id
			}
		default:
			return state;
	}
}
