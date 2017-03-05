<center-list>
	<table
		class = "ui blue table"
		show  = "{centers.length > 0}"
		style = "margin-bottom: 25px;">
		<thead>
			<tr>
				<th>Area</th>
				<th>Country</th>
				<th>Region</th>
				<th>Name</th>
				<th>Category</th>
				<th style="min-width: 160px; width: 240px; max-width: 240px; text-align: center;">
					<i class="options icon"></i> Actions
				</th>
			</tr>
		</thead>
		<tbody>
			<tr each={ centers } scope={ this }>
				<td>{area}</td>
				<td>{country}</td>
				<td>{region}</td>
				<td>{name}</td>
				<td>{category}</td>
				<td style="color: black !important;">
					<button
						class    = "ui action-btn vertical olive animated button"
						tabindex = "0"
						onclick  = { showView() }>
						<div class="hidden content">View</div>
						<div class="visible content">
							<i class="action info icon"></i>
						</div>
					</button>
					<div
						class    = "ui action-btn vertical yellow animated button"
						tabindex = "0"
						onclick  = { showForm() }>
						<div class="hidden content">Edit</div>
						<div class="visible content">
							<i class="action write icon"></i>
						</div>
					</div>
					<div
						class    = "ui action-btn vertical red animated button"
						tabindex = "0"
						onclick  = { remove() }>
						<div class="hidden content">Delete</div>
						<div class="visible content">
							<i class="action remove icon"></i>
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
					<div class="ui centered column grid">
						<div class="row">
							<riot-pagination
								show         = "{ centers.length }"
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
		show  = "{centers.length == 0}">
		<h3>No Centers !</h3>
	</div>

	<script>

		const self = this;

		showView(e) {
			return (e) => {
				self.parent.showView(e.item);
			}
		}

		showForm(e) {
			return (e) => {
				self.parent.showForm(e.item);
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
				this.getCenters({page: pageNo, limit: this.perPage});
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

		getCenters(params) {

			if (this.parent.searchQ) {
				params.keyword = this.parent.searchQ;
			}

			this.parent.opts.service.search(params, (err, response) => {
				if (!err && response.body().length) {
					let result = this.getData(response.body()[0]);
					// console.log("result");
					// console.log(result);
					if (result.centers && result.current_page_record_count > 0) {
						this.centers     = result.centers;
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
			console.log('PERFORM SEARCH', state.centers.query);
			this.getCenters(state.centers.query || this.getDefaultQueryParams());
		}

		this.on('search', (data) => {
			this.performSearch();
		});

		this.on('refresh', (data) => {
			this.getCenters(this.getDefaultQueryParams());
		});

		this.getCenters(this.getDefaultQueryParams());

	</script>

	<style scoped>
		:scope { font-size: 0.7em; }
		i.action, .action-btn { color: black !important;  }
	</style>

</center-list>

