import { SHOW_LOADER, HIDE_LOADER } from '../../constants/LoaderActions'

export default function loader(state = HIDE_LOADER, action) {
	switch (action.type) {
		case SHOW_LOADER:
			console.log("SHOW");
			return SHOW_LOADER;
		case HIDE_LOADER:
			console.log("HIDE");
			return HIDE_LOADER;
		default:
			return state;
	}
}
