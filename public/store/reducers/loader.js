import { SHOW_LOADER, HIDE_LOADER } from '../../constants/LoaderActions'

export default function loader(state = {show: "false"}, action) {
	switch (action.type) {
		case SHOW_LOADER:
			console.log("SHOW");
			return {
				show : "true"
			}
		case HIDE_LOADER:
			console.log("HIDE");
			return {
				show : "false"
			}
		default:
			return state;
	}
}
