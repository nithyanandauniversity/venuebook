<user-list>
	<table
		class = "ui green table"
		show  = "{users.length > 0}"
		style = "margin-bottom: 25px;">
		<thead>
			<tr>
				<th>Name / Email</th>
				<th>Role</th>
				<th>Center</th>
				<th style = "min-width: 160px; width: 240px; max-width: 240px; text-align: center;">
					<i class = "options icon"></i> Actions
				</th>
			</tr>
		</thead>
		<tbody>
			<tr each = "{ user in users }">
				<td>
					<label><strong>{user.first_name}</strong> {user.last_name}</label> <br />
					<em style="font-size: 0.9em;" class="meta">{user.email}</em>
				</td>
				<td>{ userRoles[user.role] }</td>
				<td>
					<div if = "{ user.role == 1 }"><strong>ALL CENTERS</strong></div>
					<div if = "{ user.role == 2 }">
						<span show="{user.user_permissions['areas']}">
							<strong>Areas: </strong> {user.user_permissions['areas']}
						</span>
						<span show="{user.user_permissions['countries']}">
							<strong>Countries: </strong> {user.user_permissions['countries']}
						</span>
						<span show="{user.user_permissions['centers']}">
							<strong>Centers: </strong> {user.user_permissions['centers'].length} Centers
						</span>
					</div>
					<div if = "{ user.center && user.center.id }">
						<strong>{user.center.name}</strong><br />
						<span style = "line-height: 1em; font-size: 0.8em;">
							{user.center.area}, {user.center.country}, {user.center.region}
						</span>
					</div>
				</td>
				<td style="color: black !important;">
					<button
						class    = "ui action-btn vertical olive animated button"
						tabindex = "0"
						onclick  = { showView() }>
						<div class = "hidden content">View</div>
						<div class = "visible content">
							<i class = "action info icon"></i>
						</div>
					</button>
					<div
						class    = "ui action-btn vertical yellow animated button"
						tabindex = "0"
						onclick  = { showForm() }>
						<div class = "hidden content">Edit</div>
						<div class = "visible content">
							<i class = "action write icon"></i>
						</div>
					</div>
					<div
						class    = "ui action-btn vertical red animated button"
						tabindex = "0"
						onclick  = { remove() }>
						<div class = "hidden content">Block</div>
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
					colspan = "6"
					style   = "border-top: 1px solid rgba(34,36,38,.1);">
					<div class = "ui centered column grid">
						<div class = "row">
							<riot-pagination
								show         = "{ users.length }"
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
						<div class = "row">
							<span class = "ui label">
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
		show  = "{users.length == 0}">
		<h3>No Users !</h3>
	</div>

	<script>

		const self = this;
		this.users   = [];
		this.perPage = 10;

		showView(e) {
			return (e) => {
				this.parent.showView(e.item);
			}
		}

		showForm(e) {
			return (e) => {
				// self.parent.showForm(e.item);
			}
		}

		getData(res) {
			return res.data();
		}

		remove(e) {
			return (e) => {
				// if (confirm("Are you sure you want to delete the center?")) {
				// 	this.parent.opts.service.remove(e.item.id, (err, response) => {
				// 		if (!err) {
				// 			console.log(response.body().data(), response.statusCode());
				// 			this.performSearch();
				// 		}
				// 		else {
				// 			console.log('some error occurred');
				// 		}
				// 	});
				// }
				// else {
				// 	// User Cancelled
				// 	console.log("Do no delete!");
				// }
			}
		}

		this.centers = [];
		this.perPage = 10;

		switchPage(pageNo) {
			if (pageNo) {
				this.getUsers({page: pageNo, limit: this.perPage});
			}
		}

		getPage() {
			return this.currentPage && this.recordCount > 1 ? this.currentPage : 1;
		}

		getDefaultQueryParams() {
			return {
				page  : this.getPage(),
				limit : this.perPage
			}
		}

		getUsers(params) {

			if (this.parent.searchQ) {
				params.keyword = this.parent.searchQ;
			}

			this.parent.opts.service.search(params, (err, response) => {
				if (!err && response.body().length) {
					let result = this.getData(response.body()[0]);
					// console.log("result");
					// console.log(result);
					if (result.users && result.current_page_record_count >= 0) {
						this.users       = result.users;
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
			});
		}

		performSearch() {
			let state = this.parent.opts.store.getState();
			console.log('PERFORM SEARCH', state.users.query);
			this.getUsers(state.users.query || this.getDefaultQueryParams());
		}

		this.on('search', (data) => {
			this.performSearch();
		});

		this.on('refresh', (data) => {
			this.getUsers(this.getDefaultQueryParams());
		});

		this.getUsers(this.getDefaultQueryParams());

		if (this.parent.opts.userRoles) {
			this.userRoles = {};
			for (let role in this.parent.opts.userRoles) {
				this.userRoles[this.parent.opts.userRoles[role]] = role.toString().split('_').join(' ');
			}
		}

	</script>

	<style scoped>
		:scope { font-size: 0.7em; }
		i.action, .action-btn { color: black !important;  }
	</style>

</user-list>

