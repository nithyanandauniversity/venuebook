import { LOGIN, PARTICIPANTS, CENTERS, PROGRAMS, EVENTS } from '../../constants/Routes'

export default function routes(state = {path: 'LOGIN', data: null}, action) {
	switch (action.type) {
		case LOGIN:
			return {
				path : 'LOGIN',
				data : action.data
			};
		case PARTICIPANTS:
			return {
				path : 'PARTICIPANTS',
				data : action.data
			};
		case CENTERS:
			return {
				path : 'CENTERS',
				data : action.data
			};
		case PROGRAMS:
			return {
				path : 'PROGRAMS',
				data : action.data
			};
		case EVENTS:
			return {
				path : 'EVENTS',
				data : action.data
			}
		default:
			return state;
	}
}
