import 'fetch';
import restful, { fetchBackend } from 'restful';

import { COUNTRIES } from '../constants/countries';
import Participant from './participant.service';
// import Event from './event.service';
// import Program from './program.service';

export default class Services {

	constructor(host) {
		const hostname = this.getHostname(host);
		const api = restful('http://' + hostname + '/api/v1', fetchBackend(fetch));

		const participantsCollection = api.all('participants');
		// const eventsCollection = api.all('events');
		// const programsCollection = api.all('programs');

		this.participantService = new Participant(api);
		// this.eventService = new Event(api);
		// this.programService = new Program(api);

		this.countries = this.generateCountriesList();
	}

	getHostname(hostname) {
		if (hostname == 'localhost') {
			return 'localhost:9292';
		}
		else {
			if (hostname.indexOf('lifebliss-singapore') >= 0) {
				return 'venuebook.lifebliss-singapore.org';
			}
		}
	}

	generateCountriesList() {
		let countries = [];

		for (let code in COUNTRIES) {
			countries.push({
				code  : code,
				value : COUNTRIES[code]
			});
		}

		return function() { return countries; };
	}


}