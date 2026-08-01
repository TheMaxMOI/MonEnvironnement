document.addEventListener("DOMContentLoaded", () => {
	const width_input = document.getElementById("width");
	const length_input = document.getElementById("length");
	const mines_input = document.getElementById("mines");
	const max_mines_output = document.getElementById("max_mines");

	function update_parameters() {
		let width = parseInt(width_input.value) || 0;
		let length = parseInt(length_input.value) || 0;
		let mines = parseInt(mines_input.value) || 0;
		return [width, length, mines];
	}

	function updateMaxMines() {
		let [width, length, mines] = update_parameters();

		const max_mines = width * length;
		max_mines_output.textContent = "MAX " + max_mines;
		mines_input.placeholder = Math.round(max_mines / 6.4);

		if (mines > max_mines) {
			mines_input.value = max_mines;
		}
	}

	width_input.addEventListener("input", updateMaxMines);
	length_input.addEventListener("input", updateMaxMines);

	updateMaxMines();
});
