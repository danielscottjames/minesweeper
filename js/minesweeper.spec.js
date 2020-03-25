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
