import 'fetch';
import restful, { fetchBackend } from 'restful';

import Participant from './participant.service';
// import Event from './event.service';
// import Program from './program.service';

export default class Services {

	constructor() {
		const api = restful('http://localhost:9292/api/v1', fetchBackend(fetch));

		const participantsCollection = api.all('participants');
		// const eventsCollection = api.all('events');
		// const programsCollection = api.all('programs');

		this.participantService = new Participant(api);
		// this.eventService = new Event(api);
		// this.programService = new Program(api);

		// Search Function test
		// this.participantService.search({page: 1, limit: 10}, (err, response) => {
		// 	console.log("err, response");
		// 	console.log(err, response);
		// });
	}


}