import { LOGIN, DASHBOARD, PARTICIPANTS, CENTERS, PROGRAMS, EVENTS, USERS, VENUES, DOWNLOADS, UPLOADS } from '../../constants/Routes'

export default function routes(state = {path: 'LOGIN', data: null}, action) {
	switch (action.type) {
		case LOGIN:
			return {
				path : 'LOGIN',
				data : action.data
			};
		case DASHBOARD:
			return {
				path : 'DASHBOARD',
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
			};
		case USERS:
			return {
				path : 'USERS',
				data : action.data
			};
		case VENUES:
			return {
				path : 'VENUES',
				data : action.data
			};
		case DOWNLOADS:
			return {
				path : 'DOWNLOADS',
				data : action.data
			};
		case UPLOADS:
			return {
				path : 'UPLOADS',
				data : action.data
			};
		default:
			return state;
	}
}
