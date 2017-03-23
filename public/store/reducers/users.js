import { LIST_USER, ADD_USER, VIEW_USER, EDIT_USER, SEARCH_USER, DELETE_USER } from '../../constants/UserActions'

export default function users(state = {view: LIST_USER, page: 1}, action) {
	switch (action.type) {
		case LIST_USER:
			return {
				view  : LIST_USER,
				page  : action.page,
				query : action.query
			}
		case ADD_USER:
			return {
				view : ADD_USER
			}
		case VIEW_USER:
			return {
				view : VIEW_USER,
				id   : action.id
			}
		case EDIT_USER:
			return {
				view : EDIT_USER,
				id   : action.id
			}
		case SEARCH_USER:
			return	{
				view  : SEARCH_USER,
				query : action.query
			}
		case DELETE_USER:
			return {
				view : DELETE_USER,
				id   : action.id
			}
		default:
			return state;
	}
}
