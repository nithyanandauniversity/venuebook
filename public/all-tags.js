riot.tag2('app', '<participants></participants>', 'app,[data-is="app"]{ font-size: 2em } app h3,[data-is="app"] h3{ color: #444 } app ul,[data-is="app"] ul{ color: #999 }', 'class="ui container"', function(opts) {
		this.subtitle = 'Easy, right?';
		this.list = [
			{ name: 'my' },
			{ name: 'little' },
			{ name: 'list' }
		];
});
riot.tag2('nav', '<div class="ui fixed"> <div class="ui inverted segment"> <div class="ui container"> <div class="ui inverted secondary pointing menu"> <div class="item"> <h2>{opts.title}</h2> </div> <a each="{navigations}" class="{name == active ? \'active item\' : \'item\'}">{name}</a> </div> </div> </div> </div>', '', '', function(opts) {
		this.navigations = [
			{ name: 'Participants' },
			{ name: 'Centers' },
			{ name: 'Events' }
		];
		this.active = 'Participants';
});

riot.tag2('participant-list', '<table class="ui blue table"> <thead> <tr> <th>#</th> <th>Full Name</th> <th>Email</th> <th>Contact</th> <th style="width: 240px; text-align: center;"> <i class="options icon"></i> Actions </th> </tr> </thead> <tbody> <tr each="{participants}"> <td>{member_id}</td> <td><strong>{first_name}</strong> {last_name}</td> <td>{email}</td> <td>{contact_number}</td> <td style="color: black !important;"> <div class="ui action-btn vertical olive animated button" tabindex="0"> <div class="hidden content">View</div> <div class="visible content"> <i class="action info icon"></i> </div> </div> <div class="ui action-btn vertical yellow animated button" tabindex="0"> <div class="hidden content">Edit</div> <div class="visible content"> <i class="action write icon"></i> </div> </div> <div class="ui action-btn vertical red animated button" tabindex="0"> <div class="hidden content">Delete</div> <div class="visible content"> <i class="action remove icon"></i> </div> </div> </td> </tr> </tbody> <tfoot></tfoot> </table>', 'participant-list,[data-is="participant-list"]{ font-size: 0.7em; } participant-list i.action,[data-is="participant-list"] i.action,participant-list .action-btn,[data-is="participant-list"] .action-btn{ color: black !important; }', '', function(opts) {
		this.participants = [
			{member_id: '1', first_name: 'Saravana', last_name: 'Balaraj', email: 'sgsaravana@gmail.com', contact_number: '(+65) 86286022'},
			{member_id: '2', first_name: 'Senthuraan', last_name: 'Ponnampalam', email: 'psenthu@gmail.com', contact_number: '(+65) 81012993'},
			{member_id: '3', first_name: 'Srinath', last_name: 'Loganathan', email: 'srinath_lsn@gmail.com', contact_number: '(+49) 17623162673'}
		]
});
riot.tag2('participant-search', '<div class="ui fluid right action left icon input"> <input type="text" placeholder="Search participants..." autocomplete="off"> <i class="search icon"></i> <div class="ui primary basic button"> <i class="add user icon"></i> New </div> </div>', 'participant-searchd,[data-is="participant-search"]d{margin-top: 5px } participant-search { margin-top: 25px; margin-bottom: 25px; }', 'class="ui container"', function(opts) {
});
riot.tag2('participants', '<participant-search></participant-search> <participant-list></participant-list>', '', '', function(opts) {
});