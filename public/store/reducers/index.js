import { combineReducers } from 'redux'

import participants from './participants';
import centers from './centers';
import programs from './programs';
import routes from './routes';

const rootReducer = combineReducers({
  participants,
  centers,
  programs,
  routes
});

export default rootReducer;
