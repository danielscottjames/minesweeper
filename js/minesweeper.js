var $jscomp=$jscomp||{};$jscomp.scope={};$jscomp.createTemplateTagFirstArg=function(a){return a.raw=a};$jscomp.createTemplateTagFirstArgWithRaw=function(a,c){a.raw=c;return a};$jscomp.arrayIteratorImpl=function(a){var c=0;return function(){return c<a.length?{done:!1,value:a[c++]}:{done:!0}}};$jscomp.arrayIterator=function(a){return{next:$jscomp.arrayIteratorImpl(a)}};$jscomp.makeIterator=function(a){var c="undefined"!=typeof Symbol&&Symbol.iterator&&a[Symbol.iterator];return c?c.call(a):$jscomp.arrayIterator(a)};
$jscomp.arrayFromIterator=function(a){for(var c,b=[];!(c=a.next()).done;)b.push(c.value);return b};$jscomp.arrayFromIterable=function(a){return a instanceof Array?a:$jscomp.arrayFromIterator($jscomp.makeIterator(a))};$jscomp.ASSUME_ES5=!1;$jscomp.ASSUME_NO_NATIVE_MAP=!1;$jscomp.ASSUME_NO_NATIVE_SET=!1;$jscomp.SIMPLE_FROUND_POLYFILL=!1;
$jscomp.defineProperty=$jscomp.ASSUME_ES5||"function"==typeof Object.defineProperties?Object.defineProperty:function(a,c,b){a!=Array.prototype&&a!=Object.prototype&&(a[c]=b.value)};$jscomp.getGlobal=function(a){a=["object"==typeof window&&window,"object"==typeof self&&self,"object"==typeof global&&global,a];for(var c=0;c<a.length;++c){var b=a[c];if(b&&b.Math==Math)return b}throw Error("Cannot find global object");};$jscomp.global=$jscomp.getGlobal(this);$jscomp.SYMBOL_PREFIX="jscomp_symbol_";
$jscomp.initSymbol=function(){$jscomp.initSymbol=function(){};$jscomp.global.Symbol||($jscomp.global.Symbol=$jscomp.Symbol)};$jscomp.SymbolClass=function(a,c){this.$jscomp$symbol$id_=a;$jscomp.defineProperty(this,"description",{configurable:!0,writable:!0,value:c})};$jscomp.SymbolClass.prototype.toString=function(){return this.$jscomp$symbol$id_};
$jscomp.Symbol=function(){function a(b){if(this instanceof a)throw new TypeError("Symbol is not a constructor");return new $jscomp.SymbolClass($jscomp.SYMBOL_PREFIX+(b||"")+"_"+c++,b)}var c=0;return a}();
$jscomp.initSymbolIterator=function(){$jscomp.initSymbol();var a=$jscomp.global.Symbol.iterator;a||(a=$jscomp.global.Symbol.iterator=$jscomp.global.Symbol("Symbol.iterator"));"function"!=typeof Array.prototype[a]&&$jscomp.defineProperty(Array.prototype,a,{configurable:!0,writable:!0,value:function(){return $jscomp.iteratorPrototype($jscomp.arrayIteratorImpl(this))}});$jscomp.initSymbolIterator=function(){}};
$jscomp.initSymbolAsyncIterator=function(){$jscomp.initSymbol();var a=$jscomp.global.Symbol.asyncIterator;a||(a=$jscomp.global.Symbol.asyncIterator=$jscomp.global.Symbol("Symbol.asyncIterator"));$jscomp.initSymbolAsyncIterator=function(){}};$jscomp.iteratorPrototype=function(a){$jscomp.initSymbolIterator();a={next:a};a[$jscomp.global.Symbol.iterator]=function(){return this};return a};$jscomp.underscoreProtoCanBeSet=function(){var a={a:!0},c={};try{return c.__proto__=a,c.a}catch(b){}return!1};
$jscomp.setPrototypeOf="function"==typeof Object.setPrototypeOf?Object.setPrototypeOf:$jscomp.underscoreProtoCanBeSet()?function(a,c){a.__proto__=c;if(a.__proto__!==c)throw new TypeError(a+" is not extensible");return a}:null;$jscomp.generator={};$jscomp.generator.ensureIteratorResultIsObject_=function(a){if(!(a instanceof Object))throw new TypeError("Iterator result "+a+" is not an object");};
$jscomp.generator.Context=function(){this.isRunning_=!1;this.yieldAllIterator_=null;this.yieldResult=void 0;this.nextAddress=1;this.finallyAddress_=this.catchAddress_=0;this.finallyContexts_=this.abruptCompletion_=null};$jscomp.generator.Context.prototype.start_=function(){if(this.isRunning_)throw new TypeError("Generator is already running");this.isRunning_=!0};$jscomp.generator.Context.prototype.stop_=function(){this.isRunning_=!1};
$jscomp.generator.Context.prototype.jumpToErrorHandler_=function(){this.nextAddress=this.catchAddress_||this.finallyAddress_};$jscomp.generator.Context.prototype.next_=function(a){this.yieldResult=a};$jscomp.generator.Context.prototype.throw_=function(a){this.abruptCompletion_={exception:a,isException:!0};this.jumpToErrorHandler_()};$jscomp.generator.Context.prototype["return"]=function(a){this.abruptCompletion_={"return":a};this.nextAddress=this.finallyAddress_};
$jscomp.generator.Context.prototype.jumpThroughFinallyBlocks=function(a){this.abruptCompletion_={jumpTo:a};this.nextAddress=this.finallyAddress_};$jscomp.generator.Context.prototype.yield=function(a,c){this.nextAddress=c;return{value:a}};$jscomp.generator.Context.prototype.yieldAll=function(a,c){var b=$jscomp.makeIterator(a),d=b.next();$jscomp.generator.ensureIteratorResultIsObject_(d);if(d.done)this.yieldResult=d.value,this.nextAddress=c;else return this.yieldAllIterator_=b,this.yield(d.value,c)};
$jscomp.generator.Context.prototype.jumpTo=function(a){this.nextAddress=a};$jscomp.generator.Context.prototype.jumpToEnd=function(){this.nextAddress=0};$jscomp.generator.Context.prototype.setCatchFinallyBlocks=function(a,c){this.catchAddress_=a;void 0!=c&&(this.finallyAddress_=c)};$jscomp.generator.Context.prototype.setFinallyBlock=function(a){this.catchAddress_=0;this.finallyAddress_=a||0};$jscomp.generator.Context.prototype.leaveTryBlock=function(a,c){this.nextAddress=a;this.catchAddress_=c||0};
$jscomp.generator.Context.prototype.enterCatchBlock=function(a){this.catchAddress_=a||0;a=this.abruptCompletion_.exception;this.abruptCompletion_=null;return a};$jscomp.generator.Context.prototype.enterFinallyBlock=function(a,c,b){b?this.finallyContexts_[b]=this.abruptCompletion_:this.finallyContexts_=[this.abruptCompletion_];this.catchAddress_=a||0;this.finallyAddress_=c||0};
$jscomp.generator.Context.prototype.leaveFinallyBlock=function(a,c){var b=this.finallyContexts_.splice(c||0)[0];if(b=this.abruptCompletion_=this.abruptCompletion_||b){if(b.isException)return this.jumpToErrorHandler_();void 0!=b.jumpTo&&this.finallyAddress_<b.jumpTo?(this.nextAddress=b.jumpTo,this.abruptCompletion_=null):this.nextAddress=this.finallyAddress_}else this.nextAddress=a};$jscomp.generator.Context.prototype.forIn=function(a){return new $jscomp.generator.Context.PropertyIterator(a)};
$jscomp.generator.Context.PropertyIterator=function(a){this.object_=a;this.properties_=[];for(var c in a)this.properties_.push(c);this.properties_.reverse()};$jscomp.generator.Context.PropertyIterator.prototype.getNext=function(){for(;0<this.properties_.length;){var a=this.properties_.pop();if(a in this.object_)return a}return null};$jscomp.generator.Engine_=function(a){this.context_=new $jscomp.generator.Context;this.program_=a};
$jscomp.generator.Engine_.prototype.next_=function(a){this.context_.start_();if(this.context_.yieldAllIterator_)return this.yieldAllStep_(this.context_.yieldAllIterator_.next,a,this.context_.next_);this.context_.next_(a);return this.nextStep_()};
$jscomp.generator.Engine_.prototype.return_=function(a){this.context_.start_();var c=this.context_.yieldAllIterator_;if(c)return this.yieldAllStep_("return"in c?c["return"]:function(a){return{value:a,done:!0}},a,this.context_["return"]);this.context_["return"](a);return this.nextStep_()};
$jscomp.generator.Engine_.prototype.throw_=function(a){this.context_.start_();if(this.context_.yieldAllIterator_)return this.yieldAllStep_(this.context_.yieldAllIterator_["throw"],a,this.context_.next_);this.context_.throw_(a);return this.nextStep_()};
$jscomp.generator.Engine_.prototype.yieldAllStep_=function(a,c,b){try{var d=a.call(this.context_.yieldAllIterator_,c);$jscomp.generator.ensureIteratorResultIsObject_(d);if(!d.done)return this.context_.stop_(),d;var e=d.value}catch(f){return this.context_.yieldAllIterator_=null,this.context_.throw_(f),this.nextStep_()}this.context_.yieldAllIterator_=null;b.call(this.context_,e);return this.nextStep_()};
$jscomp.generator.Engine_.prototype.nextStep_=function(){for(;this.context_.nextAddress;)try{var a=this.program_(this.context_);if(a)return this.context_.stop_(),{value:a.value,done:!1}}catch(c){this.context_.yieldResult=void 0,this.context_.throw_(c)}this.context_.stop_();if(this.context_.abruptCompletion_){a=this.context_.abruptCompletion_;this.context_.abruptCompletion_=null;if(a.isException)throw a.exception;return{value:a["return"],done:!0}}return{value:void 0,done:!0}};
$jscomp.generator.Generator_=function(a){this.next=function(c){return a.next_(c)};this["throw"]=function(c){return a.throw_(c)};this["return"]=function(c){return a.return_(c)};$jscomp.initSymbolIterator();this[Symbol.iterator]=function(){return this}};$jscomp.generator.createGenerator=function(a,c){var b=new $jscomp.generator.Generator_(new $jscomp.generator.Engine_(c));$jscomp.setPrototypeOf&&$jscomp.setPrototypeOf(b,a.prototype);return b};var Point=function(){};
Point.getRandomPoint=function(a,c){return{x:Math.floor(Math.random()*a),y:Math.floor(Math.random()*c)}};Point.getNeighborPoints=function(a,c,b){for(var d=[],e=a.y-1;e<=a.y+1;e++)for(var f=a.x-1;f<=a.x+1;f++)0<=f&&f<c&&0<=e&&e<b&&(f!=a.x||e!=a.y)&&d.push({x:f,y:e});return d};Point.distance=function(a,c){return Math.pow(a.x-c.x,2)+Math.pow(a.y-c.y,2)};Point.toString=function(a){return a.x+"_"+a.y};var SquareState;
(function(a){a[a.Unknown=0]="Unknown";a[a.Flagged=1]="Flagged";a[a.Question=2]="Question";a[a.Revealed=3]="Revealed"})(SquareState||(SquareState={}));function isUnknownOrQuestion(a){return a==SquareState.Unknown||a==SquareState.Question}var EMPTY=0,MINE=-1,CALL_LIMIT=Math.pow(2,12);
function logProbabilityMap(a){var c=[].concat($jscomp.arrayFromIterable(a.entries())).map(function(a){var b=$jscomp.makeIterator(a);a=b.next().value;b=b.next().value;return a.name+"::"+b}).join("\n\t");console.log("Permutations: ("+a.__permutations+") in "+a.__recursiveCalls+" calls \n\t"+c)}var Square=function(a,c){this.value=a;this.point=c;this.neighbors=new Set;this.name=Point.toString(this.point);this.state=SquareState.Unknown;this.highlight=!1};
Square.prototype.toJSON=function(){return{value:this.value,state:this.state,highlight:this.highlight}};
var MineSweeper=function(a,c,b){var d=this;this.width=a;this.height=c;this.mines=b;this.squares=new Map;this.luck=!0;this.lastTapPoint={x:0,y:0};this.init=function(){var a=!1;return function(b){if(a)throw Error("Already initialized!");a=!0;d.lastTapPoint=b;b=d.squares.get(Point.toString(b));if(!b)throw Error("Invalid starting position!");b=new Set([b].concat($jscomp.arrayFromIterable(b.neighbors)));for(var c=0;c<d.mines;){var e=d.squares.get(Point.toString(Point.getRandomPoint(d.width,d.height)));
e&&!b.has(e)&&e.value!=MINE&&(c++,d.addMine(e))}}}();this.cantBeMines=new Set;this.mustBeMines=new Set;if(1>b||b>=a*c-9||1>a||1>c)throw Error("Invalid starting game configuration!");for(b=0;b<c;b++)for(var e=0;e<a;e++)this.squares.set(Point.toString({x:e,y:b}),new Square(EMPTY,{x:e,y:b}));for(b=0;b<c;b++){e={};for(var f=0;f<a;e={$jscomp$loop$prop$square$14:e.$jscomp$loop$prop$square$14},f++)e.$jscomp$loop$prop$square$14=this.squares.get(Point.toString({x:f,y:b})),Point.getNeighborPoints({x:f,y:b},
a,c).map(function(a){return d.squares.get(Point.toString(a))}).forEach(function(a){return function(b){return a.$jscomp$loop$prop$square$14.neighbors.add(b)}}(e))}};MineSweeper.prototype.flag=function(a){"playing"==this.status()&&(this.lastTapPoint=a,(a=this.squares.get(Point.toString(a)))&&a.state!=SquareState.Revealed&&(a.highlight=!1,a.state=a.state==SquareState.Unknown?SquareState.Flagged:SquareState.Unknown))};
MineSweeper.prototype.tap=function(a){var c=this;if("playing"==this.status()&&(this.lastTapPoint=a,a=this.squares.get(Point.toString(a)))){if(a.state==SquareState.Revealed){if(0<a.value){var b=[].concat($jscomp.arrayFromIterable(filter(a.neighbors,function(a){return a.state!=SquareState.Revealed}))),d=count(b,function(a){return a.state==SquareState.Flagged});0==count(b,function(a){return a.state==SquareState.Question})&&d==a.value&&forEach(filter(b,function(a){return a.state==SquareState.Unknown}),
function(a){return c.reveal(a)})}}else a.state==SquareState.Flagged?a.state=SquareState.Question:a.state==SquareState.Question?a.state=SquareState.Flagged:a.state==SquareState.Unknown&&(this.luck&&this.tryLuck(a),this.reveal(a));"win"==this.status()&&this.squares.forEach(function(a){a.state==SquareState.Unknown&&a.value==MINE&&(a.state=SquareState.Flagged)})}};
MineSweeper.prototype.getBoard=function(){for(var a=[],c=0;c<this.height;c++){a[c]=[];for(var b=0;b<this.width;b++)a[c][b]=this.squares.get(Point.toString({x:b,y:c})).toJSON()}return a};MineSweeper.prototype.getGameState=function(){return{status:this.status(),mines:this.minesRemaining()}};
MineSweeper.prototype.prettyPrint=function(){return this.getBoard().map(function(a){return a.map(function(a){return a.state==SquareState.Unknown?"\u25a0":a.state==SquareState.Flagged?"\u0192":a.state==SquareState.Question?"?":a.value==MINE?"*":a.value==EMPTY?" ":a.value.toString()}).join("")}).join("\n")};
MineSweeper.prototype.hint=function(){var a=this.simpleHint();if(a.length)return a.map(function(a){return a.point});try{var c=$jscomp.makeIterator(this.calculateProbs()).next().value,b=this.advancedHint();if(b.length)return[b[0].point];var d=[].concat($jscomp.arrayFromIterable(filter(filter([].concat($jscomp.arrayFromIterable(c.entries())).sort(function(a,b){var c=$jscomp.makeIterator(a);c.next();c=c.next().value;var d=$jscomp.makeIterator(b);d.next();d=d.next().value;return c-d}),function(a){return $jscomp.makeIterator(a).next().value.state!=
SquareState.Revealed}),function(a){return a[0].value!=MINE})));return d.length?[d[0][0].point]:[this.randomHint().point]}catch(e){console.log(""+e)}a=this.advancedHint();return a.length?[a[0].point]:[this.randomHint().point]};
MineSweeper.prototype.randomHint=function(){var a=this,c=[].concat($jscomp.arrayFromIterable(filter(filter(this.squares.values(),function(a){return a.state==SquareState.Unknown}),function(a){return!!find(a.neighbors.values(),function(a){return a.state!=SquareState.Unknown})}))).sort(function(b,c){return Point.distance(b.point,a.lastTapPoint)-Point.distance(c.point,a.lastTapPoint)})[0];if(c)return c.value==MINE?this.addMustBeMine(c):this.addCantBeMine(c),c};
MineSweeper.prototype.simpleHint=function(){var a=this,c=this.incorrectlyFlagged();if(c.length)return c.forEach(function(a){a.state==SquareState.Flagged&&(a.highlight=!0)}),c;this.withObviousFlags(function(){});c=[].concat($jscomp.arrayFromIterable(this.nextObviousFlag()),$jscomp.arrayFromIterable(this.nextObviousTap()));return c.length?c.sort(function(b,c){return Point.distance(b[0].point,a.lastTapPoint)-Point.distance(c[0].point,a.lastTapPoint)})[0]:[]};
MineSweeper.prototype.advancedHint=function(){var a=this;return[].concat($jscomp.arrayFromIterable(filter(filter(this.mustBeMines.values(),function(a){return a.state!=SquareState.Flagged}),function(a){return a.state!=SquareState.Revealed})),$jscomp.arrayFromIterable(filter(this.cantBeMines.values(),function(a){return a.state!=SquareState.Revealed}))).sort(function(c,b){return Point.distance(c.point,a.lastTapPoint)-Point.distance(b.point,a.lastTapPoint)})};
MineSweeper.prototype.undo=function(){var a=this,c=find(this.squares.values(),function(a){return a.value==MINE&&a.state==SquareState.Revealed&&1==a.highlight});if(c){c.state=SquareState.Flagged;forEach(this.squares.values(),function(a){a.highlight=!1;a.state==SquareState.Revealed&&a.value==MINE&&(a.state=SquareState.Unknown)});this.addMustBeMine(c);try{this.calculateProbs()}finally{forEach(this.squares.values(),function(b){b.state==SquareState.Flagged&&(a.mustBeMines.has(b)||a.cantBeMines.has(b)?
a.cantBeMines.has(b)&&(b.highlight=!0):b.state=SquareState.Question)})}this.shuffle([].concat($jscomp.arrayFromIterable(filter(this.squares.values(),function(a){return a.state!=SquareState.Revealed}))))}};
MineSweeper.prototype.status=function(){for(var a=!1,c=$jscomp.makeIterator(this.squares),b=c.next();!b.done;b=c.next()){b=$jscomp.makeIterator(b.value);b.next();b=b.next().value;if(b.value==MINE&&b.state==SquareState.Revealed)return"lose";b.value!=MINE&&b.state!=SquareState.Revealed&&(a=!0)}return a?"playing":"win"};MineSweeper.prototype.minesRemaining=function(){return this.mines-count(this.squares.values(),function(a){return a.state==SquareState.Flagged})};
MineSweeper.prototype.reveal=function(a){a.value==MINE?(a.state=SquareState.Revealed,a.highlight=!0,this.squares.forEach(function(a){a.state!=SquareState.Revealed&&a.state!=SquareState.Flagged&&a.value==MINE&&(a.state=SquareState.Revealed);a.state==SquareState.Flagged&&a.value!=MINE&&(a.highlight=!0)})):(a.state=SquareState.Revealed,a.value==EMPTY&&this.revealNeighbors(a))};
MineSweeper.prototype.revealNeighbors=function(a){var c=this;a.neighbors.forEach(function(a){a.state!=SquareState.Revealed&&a.value!=MINE&&(a.state=SquareState.Revealed,a.value==EMPTY&&c.revealNeighbors(a))})};MineSweeper.prototype.addMine=function(a){a.value!=MINE&&(a.value=MINE,a.neighbors.forEach(function(a){0<=a.value&&a.value++}))};
MineSweeper.prototype.removeMine=function(a){a.value==MINE&&(a.value=count(a.neighbors,function(a){return a.value==MINE}),a.neighbors.forEach(function(a){0<a.value&&a.value--}))};
MineSweeper.prototype.incorrectlyFlagged=function(){for(var a=$jscomp.makeIterator(this.squares),c=a.next();!c.done;c=a.next())if(c=$jscomp.makeIterator(c.value),c.next(),c=c.next().value,c.state==SquareState.Revealed&&0<c.value&&count(c.neighbors,function(a){return a.state==SquareState.Flagged})>c.value)return[].concat($jscomp.arrayFromIterable(filter(c.neighbors,function(a){return a.state==SquareState.Flagged&&a.value!=MINE})));return[].concat($jscomp.arrayFromIterable(filter(this.squares.values(),
function(a){return a.state==SquareState.Flagged&&a.value!=MINE})))};
MineSweeper.prototype.nextObviousFlag=function(){for(var a=[],c=$jscomp.makeIterator(this.squares),b=c.next();!b.done;b=c.next())if(b=$jscomp.makeIterator(b.value),b.next(),b=b.next().value,b.state==SquareState.Revealed&&0<b.value){var d=count(b.neighbors,function(a){return a.state==SquareState.Flagged}),e=[].concat($jscomp.arrayFromIterable(filter(b.neighbors,function(a){return isUnknownOrQuestion(a.state)})));e.length&&e.length==b.value-d&&a.push(e)}return a};
MineSweeper.prototype.nextObviousTap=function(){for(var a=[],c=$jscomp.makeIterator(this.squares),b=c.next();!b.done;b=c.next())if(b=$jscomp.makeIterator(b.value),b.next(),b=b.next().value,b.state==SquareState.Revealed&&0<b.value){var d=count(b.neighbors,function(a){return a.state==SquareState.Flagged}),e=[].concat($jscomp.arrayFromIterable(filter(b.neighbors,function(a){return a.state==SquareState.Unknown})));d==b.value&&e.length&&a.push([b])}return a};
MineSweeper.prototype.withObviousFlags=function(a){var c=this;do{var b=this.mustBeMines.size+this.cantBeMines.size;forEach(this.squares.values(),function(a){return c.cacheSquareNeighbors(a)})}while(this.mustBeMines.size+this.cantBeMines.size>b);var d=[];[].concat($jscomp.arrayFromIterable(filter(this.squares.values(),function(a){return a.state!=SquareState.Revealed}))).forEach(function(a){if(a.state==SquareState.Flagged&&!c.mustBeMines.has(a))d.push(function(){return a.state=SquareState.Flagged}),
a.state=SquareState.Unknown;else if(c.mustBeMines.has(a)){var b=a.state;d.push(function(){return a.state=b});a.state=SquareState.Flagged}});try{return a()}finally{d.forEach(function(a){return a()})}};
MineSweeper.prototype.tryLuck=function(a){if(a.value==MINE&&!this.incorrectlyFlagged().length&&!this.nextObviousFlag().length&&!this.nextObviousTap().length)try{var c=$jscomp.makeIterator(this.calculateProbs()),b=c.next().value,d=c.next().value,e=b.get(a);b.__permutations&&e&&e<b.__permutations&&!d.find(function(a){return b.get(a)<e})&&this.shuffle(d,a)}catch(f){console.log(""+f)}};
MineSweeper.prototype.shuffle=function(a,c){var b=this;this.withObviousFlags(function(){a=a.filter(function(a){return isUnknownOrQuestion(a.state)});var d=new Set(a.filter(function(a){return a.value==MINE})),e=d.size;if(0==e)console.log("It's impossible to shuffle this board!");else{var f=a,g=f.filter(function(a){return!!find(a.neighbors,function(a){return a.state==SquareState.Revealed})});console.log("Shuffling "+e+" mines from "+f.length+" with "+g.length+" edges");for(var h=new Set,k=g,m=0;m++<
CALL_LIMIT;){if(k.length&&(k=k.filter(function(a){return!h.has(a)&&b.couldBeAMine(a,h)}),!k.length&&h.size&&!b.couldBeValidGame(h))){h=new Set;k=g;continue}var l=k.length?k:f;l.length||console.log("Error!! "+g.length+" "+f.length);l=l[Math.floor(Math.random()*l.length)];c&&l==c||!b.couldBeAMine(l,h)||h.add(l);if(h.size==e)if(b.couldBeValidGame(h)){d.forEach(function(a){return b.removeMine(a)});h.forEach(function(a){return b.addMine(a)});break}else h=new Set,k=g}m>CALL_LIMIT?console.log("Failed to shuffle the board in "+
m+"/"+CALL_LIMIT+" loops"):console.log("Shuffle the board in "+m+"/"+CALL_LIMIT+" loops")}})};MineSweeper.prototype.couldBeValidGame=function(a){if(a.size>this.mines-this.mustBeMines.size)return!1;for(var c=$jscomp.makeIterator(this.squares),b=c.next();!b.done;b=c.next())if(b=$jscomp.makeIterator(b.value),b.next(),b=b.next().value,b.state==SquareState.Revealed&&b.value!=count(b.neighbors,function(b){return b.state==SquareState.Flagged||a.has(b)}))return!1;return!0};
MineSweeper.prototype.addCantBeMine=function(a){this.cantBeMines.has(a)||(a.value==MINE?console.log("TRIED TO ADD A MINE ("+a.name+") TO CANTBEMINES!!"):(this.cantBeMines.add(a),this.cacheSquareNeighbors(a)))};MineSweeper.prototype.addMustBeMine=function(a){this.mustBeMines.has(a)||(a.value!=MINE?console.log("TRIED TO ADD A NON-MINE ("+a.name+") TO MUSTBEMINES!!"):(this.mustBeMines.add(a),this.cacheSquareNeighbors(a)))};
MineSweeper.prototype.cacheSquareNeighbors=function(a){var c=this;a.state!=SquareState.Revealed||0>=a.value||forEach(filter(a.neighbors,function(a){return a.state==SquareState.Revealed}),function(a){var b=count(a.neighbors,function(a){return a.state!=SquareState.Revealed}),e=count(a.neighbors,function(a){return a.state!=SquareState.Revealed&&c.mustBeMines.has(a)}),f=count(a.neighbors,function(a){return a.state!=SquareState.Revealed&&c.cantBeMines.has(a)});a.value==e?forEach(filter(a.neighbors,function(a){return a.state!=
SquareState.Revealed&&!c.mustBeMines.has(a)}),function(a){return c.addCantBeMine(a)}):a.value==b-f-e+e&&forEach(filter(a.neighbors,function(a){return a.state!=SquareState.Revealed&&!c.mustBeMines.has(a)&&!c.cantBeMines.has(a)}),function(a){return c.addMustBeMine(a)})})};
MineSweeper.prototype.cacheProbs=function(a){var c=this;a.__permutations&&a.forEach(function(b,d){0==b&&c.addCantBeMine(d);b==a.__permutations&&c.addMustBeMine(d)});console.log("this.cantBeMines: "+this.cantBeMines.size);console.log("this.mustBeMines: "+this.mustBeMines.size)};
MineSweeper.prototype.calculateProbs=function(){var a=this;return this.withObviousFlags(function(){var c=[].concat($jscomp.arrayFromIterable(filter(a.squares.values(),function(a){return isUnknownOrQuestion(a.state)}))),b=a.mines-a.mustBeMines.size;10<c.length&&(c=c.filter(function(a){return!!find(a.neighbors,function(a){return a.state==SquareState.Revealed})}),b=-1);var d=new Map;c.forEach(function(a){d.set(a,0)});a._calculateProbs(c,0,d,b,new Set);a.cacheProbs(d);logProbabilityMap(d);return[d,c]})};
MineSweeper.prototype._calculateProbs=function(a,c,b,d,e){b.__recursiveCalls=(b.__recursiveCalls||0)+1;if(b.__recursiveCalls==CALL_LIMIT)throw Error("Too many recursive calls ("+CALL_LIMIT+") while calculating game state!\n\t(Found "+b.__permutations+" valid game permutations)");var f=a[c];if(!f||0==d||this.mines-this.mustBeMines.size==e.size){if(0>=d||this.mines-this.mustBeMines.size==e.size){if(a=this.couldBeValidGame(e))b.__permutations=(b.__permutations||0)+1;return a}return!1}var g=!1;this.couldBeAMine(f,
e)&&(e.add(f),g=this._calculateProbs(a,c+1,b,d-1,e)||g,e["delete"](f),g&&b.set(f,(b.get(f)||0)+1));this.couldNotBeMineNot(f)&&(g=this._calculateProbs(a,c+1,b,d,e)||g);return g};MineSweeper.prototype.couldNotBeMineNot=function(a){return!this.mustBeMines.has(a)};
MineSweeper.prototype.couldBeAMine=function(a,c){if(c.has(a)||this.cantBeMines.has(a))return!1;if(this.mustBeMines.has(a))return!0;for(var b=$jscomp.makeIterator(a.neighbors),d=b.next();!d.done;d=b.next())if(d=d.value,d.state==SquareState.Revealed&&count(d.neighbors,function(a){return a.state==SquareState.Flagged||c.has(a)})>=d.value)return!1;return!0};
function filter(a,c){var b,d,e;return $jscomp.generator.createGenerator(filter,function(f){1==f.nextAddress&&(b=$jscomp.makeIterator(a),d=b.next());if(3!=f.nextAddress){if(d.done)return f.jumpTo(0);e=d.value;return c(e)?f.yield(e,3):f.jumpTo(3)}d=b.next();return f.jumpTo(2)})}function find(a,c){for(var b=$jscomp.makeIterator(a),d=b.next();!d.done;d=b.next())if(d=d.value,c(d))return d}function reduce(a,c,b){a=$jscomp.makeIterator(a);for(var d=a.next();!d.done;d=a.next())b=c(b,d.value);return b}
function forEach(a,c){for(var b=$jscomp.makeIterator(a),d=b.next();!d.done;d=b.next())c(d.value)}function count(a,c){return reduce(a,function(a,d){return a+(c(d)?1:0)},0)};