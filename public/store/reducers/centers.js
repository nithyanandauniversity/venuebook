import { LIST_CENTER, ADD_CENTER, VIEW_CENTER, EDIT_CENTER, SEARCH_CENTER, DELETE_CENTER } from '../../constants/CenterActions'

export default function centers(state = {view: LIST_CENTER, page: 1}, action) {
	switch (action.type) {
		case LIST_CENTER:
			return {
				view: LIST_CENTER,
				page: action.page,
				query: action.query
			}
		case ADD_CENTER:
			return {
				view: ADD_CENTER
			}
		case VIEW_CENTER:
			return {
				view: VIEW_CENTER,
				id: action.id
			}
		case EDIT_CENTER:
			return {
				view: EDIT_CENTER,
				id: action.id
			}
		case SEARCH_CENTER:
			return	{
				view: SEARCH_CENTER,
				query: action.query
			}
		case DELETE_CENTER:
			return {
				view: DELETE_CENTER,
				id: action.id
			}
		default:
			return state;
	}
}