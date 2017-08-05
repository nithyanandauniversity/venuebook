import { LIST_DOWNLOADS } from '../../constants/DownloadActions'

export default function downloads(state = {view: LIST_DOWNLOADS}, action) {
	switch (action.type) {
		case LIST_DOWNLOADS:
			return {
				view : LIST_DOWNLOADS
			}
		default:
			return state;
	}
}

