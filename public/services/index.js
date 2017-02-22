import 'fetch';
import restful, { fetchBackend } from 'restful';

import { COUNTRIES, DIALCODES } from '../constants/countries';
import Participant from './participant.service';
// import Event from './event.service';
// import Program from './program.service';

export default class Services {

	constructor() {

		const api = restful('/api/v1', fetchBackend(fetch));

		const participantsCollection = api.all('participants');
		// const eventsCollection = api.all('events');
		// const programsCollection = api.all('programs');

		this.participantService = new Participant(api);
		// this.eventService = new Event(api);
		// this.programService = new Program(api);

		this.countries = this.generateCountriesList();
		this.dialcodes = DIALCODES;
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