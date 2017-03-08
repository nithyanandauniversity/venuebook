import riot from 'riot';
import store from 'store/main.store';
import AllServices from './services/index';

import 'tags/login.tag!';
import 'tags/app.tag!';
import 'tags/nav.tag!';
import 'tags/pages.tag!';

import 'tags/participants.tag!';
import 'tags/participants/participant-search.tag!';
import 'tags/participants/participant-list.tag!';
import 'tags/participants/participant-form.tag!';
import 'tags/participants/participant-view.tag!';
import 'tags/participants/participant-comments.tag!';

import 'tags/centers.tag!'
import 'tags/centers/center-search.tag!';
import 'tags/centers/center-list.tag!';
import 'tags/centers/center-form.tag!';
import 'tags/centers/center-view.tag!';

import 'tags/programs.tag!'
import 'tags/programs/program-form.tag!'
import 'tags/programs/program-list.tag!'

import 'tags/venues.tag!'
import 'tags/venues/venue-list.tag!'
import 'tags/venues/venue-form.tag!'

import 'tags/events.tag!'
import 'tags/users.tag!'

import 'tags/riot-pagination.tag!';


const Services = new AllServices();

// riot.mount('*');
riot.mount('app', {store: store, services: Services});
