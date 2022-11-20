"use strict";
class Point {
    static getRandomPoint(width, height) {
        return {
            x: Math.floor(Math.random() * width),
            y: Math.floor(Math.random() * height),
        };
    }
    static getNeighborPoints(p, width, height) {
        let r = [];
        for (let y = p.y - 1; y <= p.y + 1; y++) {
            for (let x = p.x - 1; x <= p.x + 1; x++) {
                if (x >= 0 && x < width && y >= 0 && y < height
                    && !(x == p.x && y == p.y)) {
                    r.push({ x, y });
                }
            }
        }
        return r;
    }
    static distance(p1, p2) {
        return (p1.x - p2.x) ** 2 + (p1.y - p2.y) ** 2;
    }
}
Point.toString = (p) => `${p.x}_${p.y}`;
var SquareState;
(function (SquareState) {
    SquareState[SquareState["Unknown"] = 0] = "Unknown";
    SquareState[SquareState["Flagged"] = 1] = "Flagged";
    SquareState[SquareState["Question"] = 2] = "Question";
    SquareState[SquareState["Revealed"] = 3] = "Revealed";
})(SquareState || (SquareState = {}));
function isUnknownOrQuestion(state) {
    return state == SquareState.Unknown || state == SquareState.Question;
}
const EMPTY = 0;
const MINE = -1;
let CALL_LIMIT = 2 ** 12;
let SHUFFLE_LIMIT = 2 ** 14;
function logProbabilityMap(map) {
    if (true) {
        const debug = [...map.entries()].map(([k, v]) => `${k.name}::${v}`).join('\n\t');
        console.log(`Permutations: (${map.__permutations}) in ${map.__recursiveCalls} calls \n\t${debug}`);
    }
}
class Square {
    constructor(value, point) {
        this.value = value;
        this.point = point;
        this.neighbors = new Set();
        this.name = Point.toString(this.point);
        this.state = SquareState.Unknown;
        this.highlight = false;
    }
    toJSON() {
        return {
            value: this.value,
            state: this.state,
            highlight: this.highlight,
        };
    }
}
class MineSweeper {
    constructor(width, height, mines, luck = true, emptyFirstTap = true, randomHints = true) {
        this.width = width;
        this.height = height;
        this.mines = mines;
        this.luck = luck;
        this.emptyFirstTap = emptyFirstTap;
        this.randomHints = randomHints;
        this.squares = new Map();
        /** For providing hints close to the last point */
        this.lastTapPoint = { x: 0, y: 0 };
        this.debug = false;
        this.init = (() => {
            let intialized = false;
            return (point) => {
                if (intialized) {
                    throw new Error('Already initialized!');
                }
                intialized = true;
                this.lastTapPoint = point;
                const clickedSquare = this.squares.get(Point.toString(point));
                if (!clickedSquare) {
                    throw new Error('Invalid starting position!');
                }
                // The clicked square and its neighbors can not be bombs
                const safe = new Set([
                    clickedSquare,
                    ...(this.emptyFirstTap ? clickedSquare.neighbors : []),
                ]);
                let placedMines = 0;
                while (placedMines < this.mines) {
                    let square = this.squares.get(Point.toString(Point.getRandomPoint(this.width, this.height)));
                    if (square && (!(safe.has(square) || square.value == MINE))) {
                        placedMines++;
                        this.addMine(square);
                    }
                }
                // (this as any).mines = 5;
                // this.squares.forEach(s => {
                //     s.value = EMPTY;
                // });
                // this.addMine(this.squares.get('0_0')!);
                // this.addMine(this.squares.get('1_1')!);
                // this.addMine(this.squares.get('2_2')!);
                // this.addMine(this.squares.get('2_3')!);
                // this.addMine(this.squares.get('1_3')!);
                // (this as any).mines = 4;
                // this.squares.forEach(s => {
                //     s.value = EMPTY;
                // });
                // this.addMine(this.squares.get('2_1')!);
                // this.addMine(this.squares.get('2_2')!);
                // this.addMine(this.squares.get('1_2')!);
                // this.addMine(this.squares.get('2_3')!);
                // (this as any).mines = 5;
                // this.squares.forEach(s => {
                //     s.value = EMPTY;
                // });
                // this.addMine(this.squares.get('1_0')!);
                // this.addMine(this.squares.get('2_1')!);
                // this.addMine(this.squares.get('0_1')!);
                // this.addMine(this.squares.get('0_2')!);
                // this.addMine(this.squares.get('1_2')!);
            };
        })();
        this.lastHint = undefined;
        /**
         * Once we've calculated that the numbers show this
         * must or must not be a mine, that will always be true.
         *
         * This allows us to short circuit future calculations
         */
        this.cantBeMines = new Set();
        this.mustBeMines = new Set();
        if (mines < 1 || mines >= (width * height - 9) || width < 1 || height < 1) {
            throw new Error('Invalid starting game configuration!');
        }
        for (let y = 0; y < height; y++) {
            for (let x = 0; x < width; x++) {
                this.squares.set(Point.toString({ x, y }), new Square(EMPTY, { x, y }));
            }
        }
        for (let y = 0; y < height; y++) {
            for (let x = 0; x < width; x++) {
                const square = this.squares.get(Point.toString({ x, y }));
                Point.getNeighborPoints({ x, y }, width, height)
                    .map(p => this.squares.get(Point.toString(p)))
                    .forEach(neighbor => square.neighbors.add(neighbor));
            }
        }
    }
    throwIfDebugElseLog(message) {
        if (this.debug) {
            throw new Error(message);
        }
        else {
            console.log(message);
        }
    }
    debugInit(mines = []) {
        this.debug = true;
        mines.forEach(mine => {
            const square = this.squares.get(mine);
            square && this.addMine(square);
        });
    }
    flag(point) {
        if (this.status() != 'playing') {
            return;
        }
        this.lastTapPoint = point;
        const square = this.squares.get(Point.toString(point));
        if (!square || square.state == SquareState.Revealed) {
            return;
        }
        else {
            square.highlight = false;
            if (square == this.lastHint) {
                this.lastHint = undefined;
            }
            if (square.state == SquareState.Unknown) {
                square.state = SquareState.Flagged;
            }
            else {
                square.state = SquareState.Unknown;
            }
        }
    }
    tap(point) {
        if (this.status() != 'playing') {
            return;
        }
        this.lastTapPoint = point;
        const square = this.squares.get(Point.toString(point));
        if (!square) {
            return;
        }
        else if (square.state == SquareState.Revealed) {
            if (square.value > 0) {
                const neighbors = [...filter(square.neighbors, s => s.state != SquareState.Revealed)];
                const flags = count(neighbors, c => c.state == SquareState.Flagged);
                const questions = count(neighbors, c => c.state == SquareState.Question);
                if (questions == 0 && flags == square.value) {
                    forEach(filter(neighbors, n => n.state == SquareState.Unknown), n => this.reveal(n));
                }
            }
        }
        else if (square.state == SquareState.Flagged) {
            square.state = SquareState.Question;
        }
        else if (square.state == SquareState.Question) {
            square.state = SquareState.Flagged;
        }
        else if (square.state == SquareState.Unknown) {
            if (this.luck) {
                this.tryLuck(square);
            }
            this.reveal(square);
        }
        if (this.status() == 'win') {
            // Mark all other mines as flags
            this.squares.forEach(square => {
                if (square.state == SquareState.Unknown && square.value == MINE) {
                    square.state = SquareState.Flagged;
                }
            });
        }
    }
    getBoard() {
        let board = [];
        for (let y = 0; y < this.height; y++) {
            board[y] = [];
            for (let x = 0; x < this.width; x++) {
                board[y][x] = this.squares.get(Point.toString({ x, y })).toJSON();
            }
        }
        return board;
    }
    getGameState() {
        return {
            status: this.status(),
            mines: this.minesRemaining(),
        };
    }
    prettyPrint() {
        const board = this.getBoard();
        return board.map(r => r.map(s => {
            if (s.state == SquareState.Unknown) {
                return '■';
            }
            else if (s.state == SquareState.Flagged) {
                return 'ƒ';
            }
            else if (s.state == SquareState.Question) {
                return '?';
            }
            else {
                if (s.value == MINE) {
                    return '*';
                }
                else if (s.value == EMPTY) {
                    return ' ';
                }
                else {
                    return s.value.toString();
                }
            }
        }).join('')).join('\n');
    }
    hint() {
        if (this.lastHint) {
            return [this.lastHint.point];
        }
        const simpleHint = this.simpleHint();
        if (simpleHint.length) {
            return simpleHint.map(h => h.point);
        }
        // Try to brute force this bad boy
        try {
            // calculating probs may fail
            const [probs] = this.calculateProbs();
            // still try the advanced hint first
            const advancedHint = this.advancedHint();
            if (advancedHint.length) {
                return [advancedHint[0].point];
            }
            // Show the least likely squares (which would be guaranteed to not be a mine due to hint mode)
            const leastProbable = [...filter(filter(shuffle([...probs.entries()])
                    .sort(([, p1], [, p2]) => p1 - p2), ([s]) => s.state != SquareState.Revealed), s => s[0].value != MINE)];
            if (leastProbable.length
                // If luck is disabled, only show the least probable if its guaranteed to not be a mine.
                && (this.luck || leastProbable[0][1] == 0)) {
                this.lastHint = leastProbable[0][0];
                return [leastProbable[0][0].point];
            }
            else {
                const randomHint = this.randomHint();
                return randomHint ? [randomHint.point] : undefined;
            }
        }
        catch (e) {
            console.log(`${e}`);
        }
        const advancedHint = this.advancedHint();
        if (advancedHint.length) {
            return [advancedHint[0].point];
        }
        else {
            const randomHint = this.randomHint();
            return randomHint ? [randomHint.point] : undefined;
        }
    }
    randomHint() {
        if (!this.randomHints) {
            return undefined;
        }
        const hint = shuffle([...filter(filter(this.squares.values(), s => !(s.state != SquareState.Unknown)), s => !!find(s.neighbors.values(), n => n.state != SquareState.Unknown))])
            .sort((a, b) => {
            const aRevealed = count(a.neighbors, n => n.state == SquareState.Revealed);
            const bRevealed = count(b.neighbors, n => n.state == SquareState.Revealed);
            return (bRevealed - aRevealed) * 10000 + Point.distance(a.point, this.lastTapPoint) - Point.distance(b.point, this.lastTapPoint);
        })[0];
        if (hint) {
            this.lastHint = hint;
            console.log(`Random Hint @ ${hint.name}`);
            if (hint.value == MINE) {
                this.addMustBeMine(hint);
            }
            else {
                this.addCantBeMine(hint);
            }
            return hint;
        }
        return undefined;
    }
    simpleHint() {
        const incorrectlyFlagged = this.incorrectlyFlagged();
        if (incorrectlyFlagged.length) {
            incorrectlyFlagged.forEach(square => {
                if (square.state == SquareState.Flagged) {
                    square.highlight = true;
                }
                ;
            });
            return incorrectlyFlagged;
        }
        this.withObviousFlags(() => { });
        let hints = [...this.nextObviousFlag(), ...this.nextObviousTap()];
        if (hints.length) {
            return hints.sort((h1, h2) => Point.distance(h1[0].point, this.lastTapPoint) - Point.distance(h2[0].point, this.lastTapPoint))[0];
        }
        return [];
    }
    advancedHint() {
        return [...filter(filter(this.mustBeMines.values(), s => s.state != SquareState.Flagged), s => s.state != SquareState.Revealed),
            ...filter(this.cantBeMines.values(), s => s.state != SquareState.Revealed)]
            .sort((s1, s2) => Point.distance(s1.point, this.lastTapPoint) - Point.distance(s2.point, this.lastTapPoint));
    }
    undo() {
        const mine = find(this.squares.values(), square => square.value == MINE && square.state == SquareState.Revealed && square.highlight == true);
        if (mine) {
            mine.state = SquareState.Flagged;
            forEach(this.squares.values(), square => {
                square.highlight = false;
                if (square.state == SquareState.Revealed && square.value == MINE) {
                    square.state = SquareState.Unknown;
                }
            });
            this.addMustBeMine(mine);
            try {
                // Ensure we have the most up to date info
                this.calculateProbs();
            }
            catch (e) {
            }
            finally {
                forEach(this.squares.values(), square => {
                    if (square.state == SquareState.Flagged) {
                        if (!this.mustBeMines.has(square) && !this.cantBeMines.has(square)) {
                            square.state = SquareState.Question;
                        }
                        else if (this.cantBeMines.has(square)) {
                            square.highlight = true;
                        }
                    }
                });
            }
            this.shuffle([...filter(this.squares.values(), square => square.state != SquareState.Revealed)]);
        }
    }
    status() {
        let isPlaying = false;
        for (let [, square] of this.squares) {
            if (square.value == MINE && square.state == SquareState.Revealed) {
                return 'lose';
            }
            if (square.value != MINE && square.state != SquareState.Revealed) {
                isPlaying = true;
            }
        }
        return isPlaying ? 'playing' : 'win';
    }
    minesRemaining() {
        return this.mines - count(this.squares.values(), c => c.state == SquareState.Flagged);
    }
    reveal(square) {
        if (square == this.lastHint) {
            this.lastHint = undefined;
        }
        if (square.value == MINE) {
            square.state = SquareState.Revealed;
            square.highlight = true;
            this.squares.forEach(s => {
                // Reveal all unflagged bombs
                if (s.state != SquareState.Revealed && s.state != SquareState.Flagged && s.value == MINE) {
                    s.state = SquareState.Revealed;
                }
                // Reveal bad flags
                if (s.state == SquareState.Flagged && s.value != MINE) {
                    s.highlight = true;
                }
            });
        }
        else {
            square.state = SquareState.Revealed;
            if (square.value == EMPTY) {
                this.revealNeighbors(square);
            }
        }
    }
    revealNeighbors(square) {
        square.neighbors.forEach(n => {
            if (n.state != SquareState.Revealed && n.value != MINE) {
                n.state = SquareState.Revealed;
                if (n.value == EMPTY) {
                    this.revealNeighbors(n);
                }
            }
        });
    }
    addMine(square) {
        if (square.value != MINE) {
            square.value = MINE;
            square.neighbors.forEach(n => {
                if (n.value >= 0) {
                    n.value++;
                }
            });
        }
    }
    removeMine(square) {
        if (square.value == MINE) {
            square.value = count(square.neighbors, c => c.value == MINE);
            square.neighbors.forEach(n => {
                if (n.value > 0) {
                    n.value--;
                }
            });
        }
    }
    incorrectlyFlagged() {
        // Are there any numbers with more adjacent flags than possible?
        for (const [, square] of this.squares) {
            if (square.state == SquareState.Revealed && square.value > 0) {
                const flags = count(square.neighbors, c => c.state == SquareState.Flagged);
                if (flags > square.value) {
                    return [...filter(square.neighbors, n => n.state == SquareState.Flagged && n.value != MINE)];
                }
            }
        }
        // Are there any flags that aren't on actual mines?
        // (TODO: this could leak info if used as a hint... 
        //        it would be better to detect if a flag couldn't be completely correct)
        return [...filter(this.squares.values(), (square) => square.state == SquareState.Flagged && square.value != MINE)];
    }
    /**
     * Assumes all flags are correct
     */
    nextObviousFlag() {
        let r = [];
        for (const [, square] of this.squares) {
            if (square.state == SquareState.Revealed && square.value > 0) {
                const flags = count(square.neighbors, c => c.state == SquareState.Flagged);
                const unknownNeighbors = [...filter(square.neighbors, n => isUnknownOrQuestion(n.state))];
                if (unknownNeighbors.length && unknownNeighbors.length == square.value - flags) {
                    r.push(unknownNeighbors);
                }
            }
        }
        return r;
    }
    /**
     * Assumes all flags are correct
     */
    nextObviousTap() {
        let r = [];
        for (const [, square] of this.squares) {
            if (square.state == SquareState.Revealed && square.value > 0) {
                const flagged = count(square.neighbors, c => c.state == SquareState.Flagged);
                const unrevealedNeighbors = [...filter(square.neighbors, n => n.state == SquareState.Unknown)];
                if (flagged == square.value && unrevealedNeighbors.length) {
                    r.push([square]);
                }
            }
        }
        return r;
    }
    /**
     * Temporarily removes all the users flags and adds flags
     * that can be 100% deduced
     *
     * This ensures the probability algorithms have the maximum amount of info possible.
     * We can't trust the user's flags, which could be wrong or lucky guesses.
     */
    withObviousFlags(fn) {
        // This will mark all the squares as must/can't be mines
        // that can be determined just by looking at revealed numbers
        do {
            var sum = this.mustBeMines.size + this.cantBeMines.size;
            forEach(this.squares.values(), square => this.cacheSquareNeighbors(square));
        } while (this.mustBeMines.size + this.cantBeMines.size > sum);
        const toUndo = [];
        const unrevealedSquares = [...filter(this.squares.values(), s => s.state != SquareState.Revealed)];
        unrevealedSquares.forEach(square => {
            if (square.state == SquareState.Flagged && !this.mustBeMines.has(square)) {
                toUndo.push(() => square.state = SquareState.Flagged);
                square.state = SquareState.Unknown;
            }
            else if (this.mustBeMines.has(square)) {
                const old = square.state;
                toUndo.push(() => square.state = old);
                square.state = SquareState.Flagged;
            }
        });
        try {
            return fn();
        }
        finally {
            toUndo.forEach(fn => fn());
        }
    }
    /**
     * Reveals the rest of the board other than squares connected
     * to the passed in square.
     *
     * @param square
     * @param fn
     */
    withEverythingElseRevealed(square, fn) {
        let safe = new Set();
        const addToSet = (square) => {
            if (!safe.has(square)) {
                safe.add(square);
                square.neighbors.forEach(n => {
                    if (n.state != SquareState.Revealed) {
                        addToSet(n);
                    }
                });
            }
        };
        addToSet(square);
        const toUndo = [];
        forEach(this.squares.values(), (s) => {
            if (!safe.has(s) && s.state != SquareState.Revealed) {
                if (s.value == MINE) {
                    const old = s.state;
                    toUndo.push(() => s.state = old);
                    s.state = SquareState.Flagged;
                }
                else {
                    const old = s.state;
                    toUndo.push(() => s.state = old);
                    s.state = SquareState.Revealed;
                }
            }
        });
        try {
            return fn();
        }
        finally {
            toUndo.forEach(fn => fn());
            // Can't trust cached results for anything that's not in this island
            // (technically, this island is flawed too since it assumed the # of remaining mines)
            this.cantBeMines = new Set(filter(this.cantBeMines.values(), s => safe.has(s)));
            this.mustBeMines = new Set(filter(this.mustBeMines.values(), s => safe.has(s)));
        }
    }
    /**
     * In order to try luck,
     * ...the user must not have any bad flags,
     * ...nor must there be any obvious additional flags
     * ...nor must there be any obvious tiles to reveal
     */
    tryLuck(square) {
        if (square.value == MINE && !this.incorrectlyFlagged().length) {
            this.withEverythingElseRevealed(square, () => {
                try {
                    let [probs, remaining] = this.calculateProbs();
                    const total = probs.get(square);
                    if (probs.__permutations && total && total < probs.__permutations && !remaining.find(r => probs.get(r) < total)) {
                        this.shuffle(remaining, square);
                    }
                }
                catch (e) {
                    console.log(`${e}`);
                }
            });
        }
    }
    shuffle(remaining, avoid) {
        this.withObviousFlags(() => {
            // Since we may have added more obvious flags...
            remaining = remaining.filter(s => isUnknownOrQuestion(s.state));
            const minesRemaining = new Set(remaining.filter(r => r.value == MINE));
            const minesToPlace = minesRemaining.size;
            if (minesToPlace == 0) {
                console.log("It's impossible to shuffle this board!");
                return;
            }
            const tilesToPickFrom = remaining;
            const edges = tilesToPickFrom.filter(s => !!find(s.neighbors, n => n.state == SquareState.Revealed));
            console.log(`Shuffling ${minesToPlace} mines from ${tilesToPickFrom.length} with ${edges.length} edges`);
            let tempMines = new Set();
            let edgesRemaining = edges;
            let i = 0;
            while (i++ < SHUFFLE_LIMIT) {
                // It's somewhat important that this loop doesn't scale with the size of the board
                if (edgesRemaining.length) {
                    edgesRemaining = edgesRemaining.filter(s => !tempMines.has(s) && this.couldBeAMine(s, tempMines));
                    // We've placed all the edges, which means if this is a valid game we just need to randomly
                    // place the rest, so check now.
                    if (!edgesRemaining.length && tempMines.size && !this.couldBeValidGame(tempMines)) {
                        // Reset and try again...
                        tempMines = new Set();
                        edgesRemaining = edges;
                        continue;
                    }
                }
                const toPickFrom = edgesRemaining.length ? edgesRemaining : tilesToPickFrom;
                if (!toPickFrom.length) {
                    console.log('Error!! ' + edges.length + " " + tilesToPickFrom.length);
                }
                const next = toPickFrom[Math.floor(Math.random() * toPickFrom.length)];
                if ((!avoid || next != avoid) && this.couldBeAMine(next, tempMines)) {
                    tempMines.add(next);
                }
                if (tempMines.size == minesToPlace) {
                    if (this.couldBeValidGame(tempMines)) {
                        minesRemaining.forEach(m => this.removeMine(m));
                        tempMines.forEach(m => this.addMine(m));
                        break;
                    }
                    else {
                        // Reset and try again...
                        tempMines = new Set();
                        edgesRemaining = edges;
                    }
                }
            }
            if (i > SHUFFLE_LIMIT) {
                console.log(`Failed to shuffle the board in ${i}/${SHUFFLE_LIMIT} loops`);
            }
            else {
                console.log(`Shuffle the board in ${i}/${SHUFFLE_LIMIT} loops`);
            }
        });
    }
    couldBeValidGame(tempMines) {
        if (tempMines.size > (this.mines - this.mustBeMines.size)) {
            return false;
        }
        for (const [, s] of this.squares) {
            if ((s.state == SquareState.Revealed)) {
                // Remember, we're assuming all flags are Mines
                if (s.value != count(s.neighbors, c => (c.state == SquareState.Flagged) || tempMines.has(c))) {
                    return false;
                }
            }
        }
        return true;
    }
    addCantBeMine(square) {
        if (!this.cantBeMines.has(square)) {
            if (square.value == MINE) {
                this.throwIfDebugElseLog(`TRIED TO ADD A MINE (${square.name}) TO CANTBEMINES!!`);
                return;
            }
            this.cantBeMines.add(square);
            this.cacheSquareNeighbors(square);
        }
    }
    addMustBeMine(square) {
        if (!this.mustBeMines.has(square)) {
            if (square.value != MINE) {
                this.throwIfDebugElseLog(`TRIED TO ADD A NON-MINE (${square.name}) TO MUSTBEMINES!!`);
                return;
            }
            this.mustBeMines.add(square);
            this.cacheSquareNeighbors(square);
        }
    }
    cacheSquareNeighbors(square) {
        if (square.state != SquareState.Revealed || square.value <= 0) {
            return;
        }
        forEach(filter(square.neighbors, n => n.state == SquareState.Revealed), n => {
            let neighboringUnrevelead = count(n.neighbors, nn => nn.state != SquareState.Revealed); // 2
            let neighboringMines = count(n.neighbors, nn => nn.state != SquareState.Revealed && this.mustBeMines.has(nn)); // 1
            let neighboringCantBeMines = count(n.neighbors, nn => nn.state != SquareState.Revealed && this.cantBeMines.has(nn)); // 0
            if (n.value == neighboringMines) {
                // All other neighbors cant be a mine
                forEach(filter(n.neighbors, nn => nn.state != SquareState.Revealed && !this.mustBeMines.has(nn)), nn => this.addCantBeMine(nn));
            }
            else if (n.value - neighboringMines == (neighboringUnrevelead - neighboringCantBeMines)) {
                // All un-categorized neighbors must be mines
                forEach(filter(n.neighbors, nn => nn.state != SquareState.Revealed && !this.mustBeMines.has(nn) && !this.cantBeMines.has(nn)), nn => this.addMustBeMine(nn));
            }
        });
    }
    cacheProbs(probs) {
        probs.__permutations && probs.forEach((count, square) => {
            if (count == 0) {
                this.addCantBeMine(square);
            }
            if (count == probs.__permutations) {
                this.addMustBeMine(square);
            }
        });
        console.log(`this.cantBeMines: ${this.cantBeMines.size}`);
        console.log(`this.mustBeMines: ${this.mustBeMines.size}`);
    }
    /**
     * Assumes that all flags are correct
     */
    calculateProbs() {
        return this.withObviousFlags(() => {
            let remaining = [...filter(this.squares.values(), square => isUnknownOrQuestion(square.state))];
            let minesRemaining = (this.mines - this.mustBeMines.size);
            if (remaining.length > 12 && minesRemaining > 12) {
                // Only consider edge pieces
                remaining = remaining.filter(s => !!find(s.neighbors, n => n.state == SquareState.Revealed));
                minesRemaining = -1;
            }
            const probs = new Map();
            remaining.forEach(r => {
                probs.set(r, 0);
            });
            this._calculateProbs(remaining, 0, probs, minesRemaining, new Set());
            this.cacheProbs(probs);
            logProbabilityMap(probs);
            return [probs, remaining];
        });
    }
    _calculateProbs(remaining, i, probs, tempMinesLeft, tempMines) {
        probs.__recursiveCalls = (probs.__recursiveCalls || 0) + 1;
        if (probs.__recursiveCalls == CALL_LIMIT) {
            throw new Error(`Too many recursive calls (${CALL_LIMIT}) while calculating game state!\n\t(Found ${probs.__permutations} valid game permutations)`);
        }
        let square = remaining[i];
        // Temp mines of < 0 means do not need to place all the remaining mines
        // (because we're only looking at a subset of squares)
        if (!square || tempMinesLeft == 0 || (this.mines - this.mustBeMines.size) == tempMines.size) {
            if (tempMinesLeft <= 0 || (this.mines - this.mustBeMines.size) == tempMines.size) {
                const validGame = this.couldBeValidGame(tempMines);
                if (validGame) {
                    probs.__permutations = (probs.__permutations || 0) + 1;
                    forEach(tempMines, mine => {
                        probs.set(mine, (probs.get(mine) || 0) + 1);
                    });
                }
            }
            return;
        }
        // What if this was a mine?
        if (this.couldBeAMine(square, tempMines)) {
            tempMines.add(square);
            this._calculateProbs(remaining, i + 1, probs, tempMinesLeft - 1, tempMines);
            tempMines.delete(square);
        }
        // Also what if this wasn't a mine?
        this._calculateProbs(remaining, i + 1, probs, tempMinesLeft, tempMines);
    }
    couldBeAMine(square, tempMines) {
        if (tempMines.has(square) || this.cantBeMines.has(square)) {
            return false;
        }
        if (this.mustBeMines.has(square)) {
            return true;
        }
        for (const neighbor of square.neighbors) {
            if (neighbor.state != SquareState.Revealed) {
                continue;
            }
            const flags = count(neighbor.neighbors, c => c.state == SquareState.Flagged || tempMines.has(c));
            if (flags >= neighbor.value) {
                return false;
            }
        }
        return true;
    }
}
function* filter(inp, func) {
    for (const element of inp) {
        if (func(element)) {
            yield element;
        }
    }
}
function find(inp, func) {
    for (const element of inp) {
        if (func(element)) {
            return element;
        }
    }
    return undefined;
}
function reduce(inp, func, init) {
    let result = init;
    for (const element of inp) {
        result = func(result, element);
    }
    return result;
}
function forEach(inp, func) {
    for (const element of inp) {
        func(element);
    }
}
function count(inp, func) {
    return reduce(inp, (a, c) => {
        return a + (func(c) ? 1 : 0);
    }, 0);
}
function shuffle(array) {
    var currentIndex = array.length, temporaryValue, randomIndex;
    // While there remain elements to shuffle...
    while (0 !== currentIndex) {
        // Pick a remaining element...
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex -= 1;
        // And swap it with the current element.
        temporaryValue = array[currentIndex];
        array[currentIndex] = array[randomIndex];
        array[randomIndex] = temporaryValue;
    }
    return array;
}
