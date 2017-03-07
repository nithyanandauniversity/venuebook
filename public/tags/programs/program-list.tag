<program-list>
	<div class="ui segment">
		<h3>All Programs List</h3>

		<div
			class = "ui list"
			show  = "{programGroups.length > 0}">
			<div
				class = "item"
				each  = "{group in programGroups}">
				<i class="icon browser"></i>
				<div class="content" style="width: 100%;">
					<div class="header">{group.header}</div>
					<div class="ui list">
						<div
							class="item"
							each = "{program in group.programs}">
							<div class="right floated content">
								<i class="icon write" onclick="{editProgram()}"></i>
							</div>
							<div class="content">
								<i class="icon caret right"></i>
								{program.program_name}
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>


	<script>

		this.programs      = [];
		this.programGroups = [];

		getData(res) {
			return res.data();
		}

		editProgram(e) {
			return(e) => {
				console.log("e.item");
				console.log(e.item);
			}
		}

		generateProgramListByGroup() {
			let groups = {};
			for (let i = 0; i < this.programs.length; i++) {
				let program = this.programs[i];
				if (!groups[program.program_type]) {
					groups[program.program_type] = []
				}

				groups[program.program_type].push(program);
			}

			this.programGroups = [];
			for (let itm in groups) {
				this.programGroups.push({header: itm, programs: groups[itm]});
			}
		}

		loadProgramsList() {
			this.parent.opts.service.search(null, (err, response) => {
				if (!err) {
					this.programs = this.getData(response.body()[0])['programs'];
					this.generateProgramListByGroup();
				}
				else {
					this.programs = [];
				}

				this.update();
				console.log("this.programs");
				console.log(this.programs);
			});
		}

		this.on('reload', () => {
			this.loadProgramsList();
		});

		this.loadProgramsList();

	</script>

</program-list>

