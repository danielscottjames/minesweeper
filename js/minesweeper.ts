// Must define this in JavascriptCore
declare const console: {
    log: (message: string) => void;
};

abstract class Point {
    public readonly x!: number;
    public readonly y!: number;

    static toString = (p: Point) => `${p.x}_${p.y}`;

    static getRandomPoint(width: number, height: number) {
        return {
            x: Math.floor(Math.random() * width),
            y: Math.floor(Math.random() * height),
        }
    }

    static getNeighborPoints(p: Point, width: number, height: number) {
        let r: Point[] = [];
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

    static distance(p1: Point, p2: Point) {
        return (p1.x - p2.x) ** 2 + (p1.y - p2.y) ** 2;
    }
}

enum SquareState {
    Unknown, Flagged, Question, Revealed
}

function isUnknownOrQuestion(state: SquareState) {
    return state == SquareState.Unknown || state == SquareState.Question;
}

const EMPTY = 0;
const MINE = -1;
type SquareValue = typeof MINE | typeof EMPTY | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8;

let CALL_LIMIT = 2 ** 12;
let SHUFFLE_LIMIT = 2 ** 14;
type ProbabilityMap = Map<Square, number> & { __permutations?: number, __recursiveCalls?: number };

function logProbabilityMap(map: ProbabilityMap) {
    if (true) {
        const debug = [...map.entries()].map(([k, v]) => `${k.name}::${v}`).join('\n\t');
        console.log(`Permutations: (${map.__permutations}) in ${map.__recursiveCalls} calls \n\t${debug}`);
    }
}

class Square {
    public readonly neighbors = new Set<Square>();
    public readonly name = Point.toString(this.point);

    public state: SquareState = SquareState.Unknown;
    public highlight = false;

    constructor(
        public value: SquareValue,
        public readonly point: Point) {
    }

    public toJSON() {
        return {
            value: this.value,
            state: this.state,
            highlight: this.highlight,
        }
    }
}

class MineSweeper {
    private squares = new Map<string, Square>();

    /** For providing hints close to the last point */
    public lastTapPoint: Point = { x: 0, y: 0 };

    constructor(public readonly width: number,
        public readonly height: number,
        public readonly mines: number,
        public readonly luck = true,
        public readonly emptyFirstTap = true,
        public readonly randomHints = true,) {
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
                const square = this.squares.get(Point.toString({ x, y }))!;
                Point.getNeighborPoints({ x, y }, width, height)
                    .map(p => this.squares.get(Point.toString(p))!)
                    .forEach(neighbor => square.neighbors.add(neighbor));
            }
        }
    }

    private throwIfDebugElseLog(message: string) {
        if (this.debug) {
            throw new Error(message);
        } else {
            console.log(message);
        }
    }

    private debug = false;
    public debugInit(mines: string[] = []) {
        this.debug = true;
        mines.forEach(mine => {
            const square = this.squares.get(mine);
            square && this.addMine(square);
        });
    }

    public init = (() => {
        let intialized = false;
        return (point: Point) => {
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
            const safe = new Set<Square>([
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
        }
    })();

    public flag(point: Point) {
        if (this.status() != 'playing') {
            return;
        }

        this.lastTapPoint = point;
        const square = this.squares.get(Point.toString(point));

        if (!square || square.state == SquareState.Revealed) {
            return;
        } else {
            square.highlight = false;

            if (square == this.lastHint) {
                this.lastHint = undefined;
            }

            if (square.state == SquareState.Unknown) {
                square.state = SquareState.Flagged;
            } else {
                square.state = SquareState.Unknown;
            }
        }
    }

    public tap(point: Point) {
        if (this.status() != 'playing') {
            return;
        }

        this.lastTapPoint = point;
        const square = this.squares.get(Point.toString(point));

        if (!square) {
            return;
        } else if (square.state == SquareState.Revealed) {
            if (square.value > 0) {
                const neighbors = [...filter(square.neighbors, s => s.state != SquareState.Revealed)];
                const flags = count(neighbors, c => c.state == SquareState.Flagged);
                const questions = count(neighbors, c => c.state == SquareState.Question);
                if (questions == 0 && flags == square.value) {
                    forEach(filter(neighbors, n => n.state == SquareState.Unknown), n => this.reveal(n));
                }
            }
        } else if (square.state == SquareState.Flagged) {
            square.state = SquareState.Question;
        } else if (square.state == SquareState.Question) {
            square.state = SquareState.Flagged;
        } else if (square.state == SquareState.Unknown) {
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

    public getBoard() {
        let board: (ReturnType<typeof Square.prototype['toJSON']>)[][] = [];

        for (let y = 0; y < this.height; y++) {
            board[y] = [];
            for (let x = 0; x < this.width; x++) {
                board[y][x] = this.squares.get(Point.toString({ x, y }))!.toJSON();
            }
        }

        return board;
    }

    public getGameState() {
        return {
            status: this.status(),
            mines: this.minesRemaining(),
        }
    }

    public prettyPrint() {
        const board = this.getBoard();
        return board.map(r => r.map(s => {
            if (s.state == SquareState.Unknown) {
                return '■';
            } else if (s.state == SquareState.Flagged) {
                return 'ƒ';
            } else if (s.state == SquareState.Question) {
                return '?';
            } else {
                if (s.value == MINE) {
                    return '*';
                } else if (s.value == EMPTY) {
                    return ' ';
                } else {
                    return s.value.toString();
                }
            }
        }).join('')).join('\n');
    }

    public hint(): Point[] | undefined {
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
                this.lastHint = leastProbable[0]![0];
                return [leastProbable[0]![0].point];
            } else {
                const randomHint = this.randomHint();
                return randomHint ? [randomHint.point] : undefined;
            }
        } catch (e) {
            console.log(`${e}`);
        }

        const advancedHint = this.advancedHint();
        if (advancedHint.length) {
            return [advancedHint[0].point];
        } else {
            const randomHint = this.randomHint();
            return randomHint ? [randomHint.point] : undefined;
        }
    }

    private lastHint: Square | undefined = undefined;
    private randomHint() {
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
            } else {
                this.addCantBeMine(hint);
            }
            return hint;
        }

        return undefined;
    }

    private simpleHint() {
        const incorrectlyFlagged = this.incorrectlyFlagged();
        if (incorrectlyFlagged.length) {
            incorrectlyFlagged.forEach(square => {
                if (square.state == SquareState.Flagged) {
                    square.highlight = true;
                };
            })

            return incorrectlyFlagged;
        }

        this.withObviousFlags(() => { });

        let hints = [...this.nextObviousFlag(), ...this.nextObviousTap()];
        if (hints.length) {
            return hints.sort((h1, h2) => Point.distance(h1[0]!.point, this.lastTapPoint) - Point.distance(h2[0]!.point, this.lastTapPoint))[0]!;
        }

        return [];
    }

    private advancedHint() {
        return [...filter(filter(this.mustBeMines.values(), s => s.state != SquareState.Flagged), s => s.state != SquareState.Revealed),
        ...filter(this.cantBeMines.values(), s => s.state != SquareState.Revealed)]
            .sort((s1, s2) => Point.distance(s1.point, this.lastTapPoint) - Point.distance(s2.point, this.lastTapPoint));
    }

    public undo() {
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
            } catch (e) {

            } finally {
                forEach(this.squares.values(), square => {
                    if (square.state == SquareState.Flagged) {
                        if (!this.mustBeMines.has(square) && !this.cantBeMines.has(square)) {
                            square.state = SquareState.Question;
                        } else if (this.cantBeMines.has(square)) {
                            square.highlight = true;
                        }
                    }
                });
            }


            this.shuffle([...filter(this.squares.values(), square => square.state != SquareState.Revealed)]);
        }
    }

    public status(): 'win' | 'lose' | 'playing' {
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

    public minesRemaining() {
        return this.mines - count(this.squares.values(), c => c.state == SquareState.Flagged);
    }

    private reveal(square: Square) {
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
            })
        } else {
            square.state = SquareState.Revealed;
            if (square.value == EMPTY) {
                this.revealNeighbors(square);
            }
        }
    }

    private revealNeighbors(square: Square) {
        square.neighbors.forEach(n => {
            if (n.state != SquareState.Revealed && n.value != MINE) {
                n.state = SquareState.Revealed;

                if (n.value == EMPTY) {
                    this.revealNeighbors(n);
                }
            }
        });
    }

    private addMine(square: Square) {
        if (square.value != MINE) {
            square.value = MINE;
            square.neighbors.forEach(n => {
                if (n.value >= 0) {
                    n.value++;
                }
            });
        }
    }

    private removeMine(square: Square) {
        if (square.value == MINE) {
            square.value = count(square.neighbors, c => c.value == MINE) as SquareValue;
            square.neighbors.forEach(n => {
                if (n.value > 0) {
                    n.value--;
                }
            });
        }
    }

    private incorrectlyFlagged() {
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
    private nextObviousFlag() {
        let r: Square[][] = [];

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
    private nextObviousTap() {
        let r: Square[][] = [];

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
    private withObviousFlags<G>(fn: () => G) {
        // This will mark all the squares as must/can't be mines
        // that can be determined just by looking at revealed numbers
        do {
            var sum = this.mustBeMines.size + this.cantBeMines.size;
            forEach(this.squares.values(), square => this.cacheSquareNeighbors(square));
        } while (this.mustBeMines.size + this.cantBeMines.size > sum);

        const toUndo: (() => void)[] = [];

        const unrevealedSquares = [...filter(this.squares.values(), s => s.state != SquareState.Revealed)];

        unrevealedSquares.forEach(square => {
            if (square.state == SquareState.Flagged && !this.mustBeMines.has(square)) {
                toUndo.push(() => square.state = SquareState.Flagged);
                square.state = SquareState.Unknown;
            } else if (this.mustBeMines.has(square)) {
                const old = square.state;
                toUndo.push(() => square.state = old);
                square.state = SquareState.Flagged;
            }
        });

        try {
            return fn();
        } finally {
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
    private withEverythingElseRevealed<G>(square: Square, fn: () => G) {
        let safe = new Set<Square>();
        const addToSet = (square: Square) => {
            if (!safe.has(square)) {
                safe.add(square);
                square.neighbors.forEach(n => {
                    if (n.state != SquareState.Revealed) {
                        addToSet(n);
                    }
                });
            }
        }
        addToSet(square);

        const toUndo: (() => void)[] = [];
        forEach(this.squares.values(), (s) => {
            if (!safe.has(s) && s.state != SquareState.Revealed) {
                if (s.value == MINE) {
                    const old = s.state;
                    toUndo.push(() => s.state = old);
                    s.state = SquareState.Flagged;
                } else {
                    const old = s.state;
                    toUndo.push(() => s.state = old);
                    s.state = SquareState.Revealed;
                }
            }
        });

        try {
            return fn();
        } finally {
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
    private tryLuck(square: Square) {
        if (square.value == MINE && !this.incorrectlyFlagged().length) {
            this.withEverythingElseRevealed(square, () => {
                try {
                    let [probs, remaining] = this.calculateProbs();
                    const total = probs.get(square);

                    if (probs.__permutations && total && total < probs.__permutations && !remaining.find(r => probs.get(r)! < total)) {
                        this.shuffle(remaining, square);
                    }
                } catch (e) {
                    console.log(`${e}`);
                }
            });
        }
    }

    private shuffle(remaining: Square[], avoid?: Square) {
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

            let tempMines = new Set<Square>();
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
                        tempMines = new Set<Square>();
                        edgesRemaining = edges;
                        continue;
                    }
                }


                const toPickFrom = edgesRemaining.length ? edgesRemaining : tilesToPickFrom;
                if (!toPickFrom.length) {
                    console.log('Error!! ' + edges.length + " " + tilesToPickFrom.length);
                }
                const next = toPickFrom[Math.floor(Math.random() * toPickFrom.length)]!;

                if ((!avoid || next != avoid) && this.couldBeAMine(next, tempMines)) {
                    tempMines.add(next);
                }

                if (tempMines.size == minesToPlace) {
                    if (this.couldBeValidGame(tempMines)) {
                        minesRemaining.forEach(m => this.removeMine(m));
                        tempMines.forEach(m => this.addMine(m));
                        break;
                    } else {
                        // Reset and try again...
                        tempMines = new Set<Square>();
                        edgesRemaining = edges;
                    }
                }
            }

            if (i > SHUFFLE_LIMIT) {
                console.log(`Failed to shuffle the board in ${i}/${SHUFFLE_LIMIT} loops`);
            } else {
                console.log(`Shuffle the board in ${i}/${SHUFFLE_LIMIT} loops`);
            }
        });
    }

    private couldBeValidGame(tempMines: Set<Square>) {
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

    /**
     * Once we've calculated that the numbers show this
     * must or must not be a mine, that will always be true.
     * 
     * This allows us to short circuit future calculations
     */
    private cantBeMines = new Set<Square>();
    private mustBeMines = new Set<Square>();
    private addCantBeMine(square: Square) {
        if (!this.cantBeMines.has(square)) {
            if (square.value == MINE) {
                this.throwIfDebugElseLog(`TRIED TO ADD A MINE (${square.name}) TO CANTBEMINES!!`);
                return;
            }
            this.cantBeMines.add(square);
            this.cacheSquareNeighbors(square);
        }
    }
    private addMustBeMine(square: Square) {
        if (!this.mustBeMines.has(square)) {
            if (square.value != MINE) {
                this.throwIfDebugElseLog(`TRIED TO ADD A NON-MINE (${square.name}) TO MUSTBEMINES!!`);
                return;
            }
            this.mustBeMines.add(square);
            this.cacheSquareNeighbors(square);
        }
    }
    private cacheSquareNeighbors(square: Square) {
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
            } else if (n.value - neighboringMines == (neighboringUnrevelead - neighboringCantBeMines)) {
                // All un-categorized neighbors must be mines
                forEach(filter(n.neighbors, nn => nn.state != SquareState.Revealed && !this.mustBeMines.has(nn) && !this.cantBeMines.has(nn)), nn => this.addMustBeMine(nn));
            }
        });
    }
    private cacheProbs(probs: ProbabilityMap) {
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
    private calculateProbs(): [ProbabilityMap, Square[]] {
        return this.withObviousFlags(() => {
            let remaining = [...filter(this.squares.values(), square => isUnknownOrQuestion(square.state))];
            let minesRemaining = (this.mines - this.mustBeMines.size);
            if (remaining.length > 12 && minesRemaining > 12) {
                // Only consider edge pieces
                remaining = remaining.filter(s => !!find(s.neighbors, n => n.state == SquareState.Revealed));
                minesRemaining = -1;
            }

            const probs: ProbabilityMap = new Map<Square, number>();
            remaining.forEach(r => {
                probs.set(r, 0);
            });

            this._calculateProbs(remaining, 0, probs, minesRemaining, new Set());

            this.cacheProbs(probs);
            logProbabilityMap(probs);

            return [probs, remaining];
        });
    }

    private _calculateProbs(remaining: Square[], i: number, probs: ProbabilityMap, tempMinesLeft: number, tempMines: Set<Square>) {
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
                        probs.set(mine, (probs.get(mine) || 0) + 1)
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

    private couldBeAMine(square: Square, tempMines: Set<Square>) {
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

function* filter<T>(inp: Iterable<T>, func: (t: T) => boolean): Iterable<T> {
    for (const element of inp) {
        if (func(element)) {
            yield element;
        }
    }
}

function find<T>(inp: Iterable<T>, func: (t: T) => boolean): T | undefined {
    for (const element of inp) {
        if (func(element)) {
            return element;
        }
    }

    return undefined;
}

function reduce<T, V>(inp: Iterable<T>, func: (prev: V, t: T) => V, init: V): V {
    let result = init;
    for (const element of inp) {
        result = func(result, element);
    }
    return result;
}

function forEach<T>(inp: Iterable<T>, func: (next: T) => void): void {
    for (const element of inp) {
        func(element);
    }
}

function count<T>(inp: Iterable<T>, func: (next: T) => boolean) {
    return reduce(inp, (a, c) => {
        return a + (func(c) ? 1 : 0);
    }, 0);
}

function shuffle<G>(array: G[]) {
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