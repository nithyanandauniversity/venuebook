<event-past>

	<table
		class = "ui orange table"
		show  = "{events.length > 0}"
		style = "margin-bottom: 25px;">
		<thead>
			<tr>
				<th>Program</th>
				<th>Name</th>
				<th>Start Date</th>
				<th>End Date</th>
				<th style="min-width: 160px; width: 240px; max-width: 240px; text-align: center;">
					<i class="options icon"></i> Actions
				</th>
			</tr>
		</thead>
		<tbody>
			<tr each = { events } scope = { this }>
				<td>
					{program.program_name}
					<div class="meta">({program.program_type})</div>
				</td>
				<td>{name || '-'}</td>
				<td>{format(start_date, 'date', 'fullDate')}</td>
				<td>{end_date ? format(end_date, 'date', 'fullDate') : '-'}</td>
				<td>
					<button
						class    = "ui action-btn vertical olive animated button"
						tabindex = "0"
						onclick  = "{ showView() }">
						<div class = "hidden content">View</div>
						<div class = "visible content">
							<i class = "action info icon"></i>
						</div>
					</button>
					<div
						class    = "ui action-btn vertical yellow animated button"
						tabindex = "0"
						show     = "{currentUser.role <= 4}"
						onclick  = "{ showForm() }">
						<div class = "hidden content">Edit</div>
						<div class = "visible content">
							<i class = "action write icon"></i>
						</div>
					</div>
					<div
						class    = "ui action-btn vertical red animated button"
						tabindex = "0"
						show     = "{currentUser.role <= 3}"
						onclick  = "{ remove() }">
						<div class = "hidden content">Delete</div>
						<div class = "visible content">
							<i class = "action remove icon"></i>
						</div>
					</div>
				</td>
			</tr>
		</tbody>
		<tfoot>
			<tr>
				<td
					colspan = "5"
					style   = "border-top: 1px solid rgba(34,36,38,.1);">
					<div class="ui centered column grid">
						<div class="row">
							<riot-pagination
								show         = "{ events.length }"
								current-page = "{ currentPage }"
								per-page     = "{ perPage }"
								page-changed = "{ switchPage }"
								page-count   = "{ pageCount }"
								record-count = "{ recordCount }"
								max-buttons  = "8"
								show-first   = "true"
								show-last    = "true"
								show-next    = "true"
								show-prev    = "true">
							</riot-pagination>
						</div>
						<div class="row">
							<span class="ui label">
								Showing { recordRange } / { recordCount } records in { pageCount } pages
							</span>
						</div>
					</div>
				</td>
			</tr>
		</tfoot>
	</table>

	<div
		class = "ui message red"
		show  = "{events.length == 0}">
		<h3>No Past Events !</h3>
	</div>

	<script>

		this.events      = [];
		this.currentUser = this.parent.opts.store.getState().routes.data;

		this.perPage = 10;

		showView(e) {
			return(e) => {
				this.parent.viewEvent(e.item);
			}
		}

		showForm(e) {
			return(e) => {
				this.parent.editEvent(e.item);
			}
		}

		remove(e) {
			return(e) => {
				if (confirm("Are you sure you want to delete the Event?")) {
					this.parent.removeEvent(e.item);
				}
			}
		}

		getData(res) {
			return res.data();
		}

		switchPage(pageNo) {
			if (pageNo) {
				this.getPast({page: pageNo, limit: this.perPage});
			}
		}

		getPage() {
			return this.currentPage && this.recordCount > 1 ? this.currentPage : 1;
		}

		getDefaultQueryParams() {
			return {
				page  : this.getPage(),
				limit : this.perPage,
			}
		}

		getPast(params) {
			params.version = Date.now();
			// if (this.parent.searchQ) {
			// 	params.keyword = this.parent.searchQ;
			// }

			if (this.currentUser) {
				params.center_id = this.currentUser.center_id;
			}

			this.parent.opts.service.getPast(params, (err, response) => {
				if (!err && response.body().length) {
					let result = this.getData(response.body()[0]);

					if (result.events && result.current_page_record_count > 0) {
						this.events      = result.events;
						this.currentPage = result.current_page;
						this.pageCount   = result.page_count;
						this.firstPage   = result.first_page;
						this.lastPage    = result.last_page;
						this.recordRange = result.current_page_record_range.split('..').join(' to ');
						this.recordCount = result.pagination_record_count;
					}
					else {
						// NO RESULTS
					}
					this.update();
					this.tags['riot-pagination'].trigger('refresh');
				}
				else {
					console.log("ERROR !");
				}
				// this.update();
			});
		}

		performSearch() {
			let state = this.parent.opts.store.getState();
			// console.log('PERFORM SEARCH', state.participants.query);
			this.getPast(state.events.query || this.getDefaultQueryParams());
		}

		this.performSearch();

		this.on('reload', () => {
			this.performSearch();
		});

	</script>

	<style scoped>
		:scope { font-size: 0.65em; }
		i.action, .action-btn { color : black !important;  }
		.meta {
			color      : #bbb;
			margin-top : 3px;
		}
	</style>

</event-past>

