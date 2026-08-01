// --- Global Constants ---
const GameState = Object.freeze({
    LOST: -1,
    NONE: 0,
    WON: 1,
});

const CellState = Object.freeze({
    HIDDEN: 0,
    REVEALED: 1,
    FLAGGED: 2
});

const TileType = Object.freeze({
    MINE: -1,
    EMPTY: 0
});

const game = {
    length: 16,
    width: 16,
    mines: 40,
    upperlayer: [],
    lowerlayer: [],
    dom_grid: [],
    state: GameState.NONE,
    has_started: false,
    safe_cells_remaining: 0,
    remaing_mines: 40
};

// --- I/O ---
const width_input = document.getElementById("width");
const length_input = document.getElementById("length");
const mines_input = document.getElementById("mines");
const start_button = document.getElementById("start_button");
const boardDiv = document.getElementById("board");
const text_box_input = document.getElementById("game_text_box");

// --- Interface ---

start_button.addEventListener("click", main);

boardDiv.addEventListener("contextmenu", (event) => event.preventDefault());

boardDiv.addEventListener("mousedown", (event) => {
    if (!event.target.classList.contains("cell")) {
        return;
    }
    if (game.state !== GameState.NONE) {
        return;
    }

    const x = parseInt(event.target.dataset.x);
    const y = parseInt(event.target.dataset.y);

    // Left Click
    if (event.button === 0) {
        handle_left_click(x, y);
    }
    // Right Click
    else if (event.button === 2) {
        handle_right_click(x, y);
    }
});

// --- Core Logic ---

function handle_left_click(x, y) {
    if (!game.has_started) {
        game.has_started = true;
        init_lower_layer(game.length, game.width, game.mines, x, y);
        update_text_box("PLAYING");
    }

    if (game.upperlayer[y][x] === CellState.FLAGGED ||
        game.upperlayer[y][x] === CellState.REVEALED) {
        return;
    }

    const content = game.lowerlayer[y][x];

    if (content === TileType.MINE) {
        game.state = GameState.LOST;
        reveal_all_mines();
        update_text_box("You Lost!");
    } else {
        propagate_reveal(x, y);
        check_win_condition();
        update_text_box("PLAYING");
    }

    render_grid();
}

function handle_right_click(x, y) {
    const current = game.upperlayer[y][x];
    if (current === CellState.HIDDEN) {
        game.upperlayer[y][x] = CellState.FLAGGED;
        game.remaing_mines--;
    } else if (current === CellState.FLAGGED) {
        game.upperlayer[y][x] = CellState.HIDDEN;
        game.remaing_mines++;
    }

    update_text_box("PLAYING - LEFT MINES: " +game.remaing_mines);
    render_grid();
}

function propagate_reveal(x, y) {
    if (x < 0 || x >= game.width || y < 0 || y >= game.length) {
        return;
    }
    if (game.upperlayer[y][x] !== CellState.HIDDEN) {
        return;
    }

    game.upperlayer[y][x] = CellState.REVEALED;
    game.safe_cells_remaining--;

    if (game.lowerlayer[y][x] === TileType.EMPTY) {
        const neighbors_list = get_neighbors(x, y, game.length, game.width);
        for (const [nx, ny] of neighbors_list) {
            propagate_reveal(nx, ny);
        }
    }
}

function check_win_condition() {
    if (game.safe_cells_remaining === 0 && game.state !== GameState.LOST) {
        game.state = GameState.WON;
        update_text_box("You Won!");
        flag_remaining_mines();
    }
}

// --- Data Layer Generation ---

function init_upper_layer(length, width) {
    game.upperlayer = [];
    game.dom_grid = [];

    boardDiv.innerHTML = "";
    boardDiv.style.gridTemplateColumns = `repeat(${width}, 32px)`;

    for (let y = 0; y < length; y++) {
        const row_data = [];
        const row_dom = [];

        for (let x = 0; x < width; x++) {
            row_data.push(CellState.HIDDEN);

            const cell = document.createElement("div");
            cell.className = "cell";
            cell.dataset.x = x;
            cell.dataset.y = y;
            boardDiv.appendChild(cell);

            row_dom.push(cell);
        }

        game.upperlayer.push(row_data);
        game.dom_grid.push(row_dom);
    }
}

function init_lower_layer(length, width, mines, safe_x, safe_y) {
    game.lowerlayer = [];

    for (let y = 0; y < length; y++) {
        const row = new Array(width).fill(TileType.EMPTY);

        game.lowerlayer.push(row);
    }

    let placed = 0;
    while (placed < mines) {
        const rx = Math.floor(Math.random() * width);
        const ry = Math.floor(Math.random() * length);

        if (game.lowerlayer[ry][rx] === TileType.MINE) {
            continue;
        }

        if (Math.abs(rx - safe_x) <= 1 && Math.abs(ry - safe_y) <= 1) {
            continue;
        }

        game.lowerlayer[ry][rx] = TileType.MINE;
        placed++;
    }

    for (let y = 0; y < length; y++) {
        for (let x = 0; x < width; x++) {
            if (game.lowerlayer[y][x] === TileType.MINE) {
                continue;
            }

            let count = 0;
            const neighbors = get_neighbors(x, y, length, width);
            for (const [nx, ny] of neighbors) {
                if (game.lowerlayer[ny][nx] === TileType.MINE) {
                    count++;
                }
            }

            game.lowerlayer[y][x] = count;
        }
    }
}

// --- Helpers ---

function get_neighbors(x, y, length, width) {
    const offsets = [
        [-1,-1], [-1,0], [-1,1],
        [ 0,-1],         [ 0,1],
        [ 1,-1], [ 1,0], [ 1,1]
    ];

    const result = [];
    for (const [dx, dy] of offsets) {
        const nx = x + dx;
        const ny = y + dy;
        if (nx >= 0 && nx < width && ny >= 0 && ny < length) {
            result.push([nx, ny]);
        }
    }

    return result;
}

function reveal_all_mines() {
    for (let y = 0; y < game.length; y++) {
        for (let x = 0; x < game.width; x++) {
            if (game.lowerlayer[y][x] === TileType.MINE) {
                game.upperlayer[y][x] = CellState.REVEALED;
            }
        }
    }
}

function flag_remaining_mines() {
    for (let y = 0; y < game.length; y++) {
        for (let x = 0; x < game.width; x++) {
            if (game.lowerlayer[y][x] === TileType.MINE) {
                game.upperlayer[y][x] = CellState.FLAGGED;
            }
        }
    }
}

// --- Display Functions ---

function render_grid() {
    for (let y = 0; y < game.length; y++) {
        for (let x = 0; x < game.width; x++) {
            const cellState = game.upperlayer[y][x];
            const cellValue = game.lowerlayer[y][x];
            const cellElement = game.dom_grid[y][x];

            cellElement.className = "cell";
            cellElement.textContent = "";

            if (cellState === CellState.FLAGGED) {
                cellElement.textContent = "f";
                cellElement.classList.add("flagged");
            }
            else if (cellState === CellState.REVEALED) {
                cellElement.classList.add("revealed");

                if (cellValue === TileType.MINE) {
                    cellElement.textContent = "¤";
                    cellElement.classList.add("mine");
                }
                else if (cellValue > 0) {
                    cellElement.textContent = cellValue;
                    cellElement.setAttribute("data-num", cellValue);
                }
            }
        }
    }
}

function update_text_box(msg) {
    text_box_input.innerHTML = msg;
}

// --- Main ---

function update_parameters() {
    let width = parseInt(width_input.value) || 16;
    let length = parseInt(length_input.value) || 16;
    let mines = parseInt(mines_input.value) || 40;

    if (mines >= width * length) mines = Math.floor((width * length) / 4);

    return [width, length, mines];
}

function reset() {
    game.state = GameState.NONE;
    game.has_started = false;
    update_text_box("READY");
}

function main() {
    reset();

    [game.width, game.length, game.mines] = update_parameters();

    game.safe_cells_remaining = (game.width * game.length) - game.mines;
    game.remaing_mines = game.mines;

    init_upper_layer(game.length, game.width);
}

main();
