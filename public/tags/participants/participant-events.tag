<participant-events>

	<div
		class = "ui segment"
		style = "min-height: 120px;">

		<h3>
			<i class="orange icon unordered list"></i>Events ({opts.count})
			<button
				if      = "{opts.count > 0}"
				class   = "ui icon tiny button basic orange right floated"
				onclick = "{ loadEvents() }">
				{loaded ? 'Reload' : 'Show'} <i class="icon caret down"></i>
			</button>
		</h3>

		<div
			class = "ui segment comments"
			show  = "{events.length > 0}"
			style = "overflow-y: scroll; max-height: 200px;">
			<div
				class = "comment"
				each  = "{event in events}"
				style = "border-bottom: 1px solid #ccc;">
				<div class="content">
					<a href="" class="author">
						{ event.program.program_name }
						<span class="ui label blue">{event.program.program_type}</span>
					</a>
					<div class="metadata">
						<span>{event.start_date}</span>
						<span show="{event.end_date}"> - {event.end_date}</span>
					</div>
					<div class="text">
						<h5>{event.name}</h5>
					</div>
				</div>
			</div>
		</div>

	</div>


	<script>
		this.loaded = false;
		this.events = [];

		loadEvents(e) {
			return(e) => {
				this.parent.loadEvents((data) => {
					this.events = data[0].data();
					this.loaded = true;
					this.update();
				});
			}
		}

	</script>

</participant-events>
