import riot from 'riot';

import store from 'store/main.store';

import 'tags/nav.tag!';
import 'tags/app.tag!';
import 'tags/participants.tag!';
import 'tags/participant-list.tag!';
import 'tags/participant-search.tag!';

// riot.mount('*');
riot.mount('nav');
riot.mount('app', {store: store});
