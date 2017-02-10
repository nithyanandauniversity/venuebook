riot.tag2('app', '<h3>{opts.title}</h3> <p>{subtitle}</p> <ul> <li each="{list}">{name}</li> </ul>', 'app,[data-is="app"]{ font-size: 2rem } app h3,[data-is="app"] h3{ color: #444 } app ul,[data-is="app"] ul{ color: #999 }', 'class="ui container"', function(opts) {
		this.subtitle = 'Easy, right?';
		this.list = [
			{ name: 'my' },
			{ name: 'little' },
			{ name: 'list' }
		];
});
riot.tag2('nav', '<div class="ui fixed"> <div class="ui container menu"> <div class="item"> <h2>{opts.title}</h2> </div> <a each="{navigations}" class="item">{name}</a> </div> </div>', '', '', function(opts) {

		this.navigations = [
			{ name: 'Participants' },
			{ name: 'Centers' },
			{ name: 'Events' }
		];
});
