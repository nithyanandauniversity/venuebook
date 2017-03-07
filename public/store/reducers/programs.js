import { ADD_PROGRAM, EDIT_PROGRAM } from '../../constants/ProgramActions'

export default function programs(state = {view: ADD_PROGRAM}, action) {
	switch (action.type) {
		case ADD_PROGRAM:
			return {
				view: ADD_PROGRAM
			}
		case EDIT_PROGRAM:
			return {
				view: EDIT_PROGRAM,
				id: action.id
			}
		default:
			return state;
	}
}