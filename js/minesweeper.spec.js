"use strict";
require('vm').runInThisContext(require('fs').readFileSync('./minesweeper.js').toString());
for (let i = 0; i < 100; i++) {
    let width = 4 + Math.floor(Math.random() * 96);
    let height = 4 + Math.floor(Math.random() * 96);
    let mines = 1 + Math.floor(Math.random() * (width * height - 10));
    let x = Math.floor(Math.random() * width);
    let y = Math.floor(Math.random() * height);
    const game = new MineSweeper(width, height, mines);
    game.init({ x, y });
    // Sanity check the numbers
    const squares = game.squares;
    squares.forEach(square => {
        if (square.value != MINE) {
            const calculatedValue = [...square.neighbors].reduce((a, c) => a + (c.value == MINE ? 1 : 0), 0);
            if (calculatedValue != square.value) {
                squares.forEach(s => s.state = SquareState.Revealed);
                console.log(game.prettyPrint());
                throw new Error(`Square has value ${square.value} but calculatedValue ${calculatedValue}`);
            }
        }
    });
    process.stdout.write('.');
}
process.stdout.write('\n');
(function () {
    const MINES = [
        '7_0', '7_1', '8_1', '1_2', '5_2', '0_3', '7_3', '8_3', '6_4', '8_4', '0_6', '7_8', '1_10', '4_10', '3_11', '7_11', '2_12', '2_13',
    ];
    const game = new MineSweeper(9, 14, MINES.length, true, true, false);
    game.debugInit(MINES);
    game.tap({ x: 3, y: 5 });
    game.tap({ x: 6, y: 4 });
})();
