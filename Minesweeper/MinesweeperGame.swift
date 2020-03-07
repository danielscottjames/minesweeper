//
//  MinesweeperGame.swift
//  Minesweeper
//
//  Created by Daniel James on 12/29/15.
//  Copyright © 2015 developersBliss. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc enum GameState :Int {
    case FirstMove, Playing, Finished
}

@objc protocol MinesweeperTimerDelegate {
    func timeChanged(time :Int);
}

@objc class MinesweeperGame : NSObject {
    private static var source : String? = {
        guard let url = Bundle.main.path(forResource: "minesweeper", ofType: "js", inDirectory: nil, forLocalization: nil) else {
            return nil
        }
        guard let source = try? NSString(contentsOfFile: url, encoding: String.Encoding.utf8.rawValue) else {
            return nil
        }
        
        return "\(source)"
    }()
    
    let context = JSContext()!
    let model: JSValue;
    
    @objc let difficulty :DifficultyLevel;
    @objc let width:Int
    @objc let height:Int
    @objc let mines:Int
    
    @objc var state: GameState {
        didSet {
            if (state == .Playing) {
                startTimer();
            } else if let timer = _timer {
                timer.invalidate()
                _timer = nil
            }
        }
    }
    
    @objc var isPaused :Bool {
        didSet {
            if (isPaused) {
                stopTimer();
            } else if (!isPaused && state == .Playing) {
                startTimer();
            }
        }
    }
    
    @objc var timerDelegate :MinesweeperTimerDelegate?
    
    
    @objc private(set) var time :Int = 0;
    private var _timer: Timer?;
    
    @objc init(withDifficulty _difficulty:DifficultyLevel, withWidth _width:Int, withHeight _height:Int, withMines _mines:Int) {
        difficulty = _difficulty;
        width = _width;
        height = _height;
        mines = _mines;
        
        state = .FirstMove;
        isPaused = false;
        time = 0;
        
        context.exceptionHandler = { context, exception in
            print("JS EXCEPTION:")
            print(exception!.toString()!)
        }
        context.evaluateScript(MinesweeperGame.source);
        model = (context.evaluateScript("MineSweeper")?.construct(withArguments: [width, height, mines]))!
    }
    
    @objc func initModel(x: Int, y: Int) {
        model.invokeMethod("init", withArguments: [["x":x, "y":y]]);
    }
    
    @objc func getBoard() -> [[Dictionary<String, Any>]] {
        return model.invokeMethod("getBoard", withArguments: []).toArray() as! [[Dictionary<String, Any>]];
    }
    
    @objc func getGameState() -> Dictionary<String, Any> {
        return model.invokeMethod("getGameState", withArguments: [])?.toDictionary() as! Dictionary<String, Any>;
    }
    
    @objc func flag(x: Int, y: Int) {
        model.invokeMethod("flag", withArguments: [["x":x, "y":y]]);
    }
    
    @objc func tap(x: Int, y: Int) {
        model.invokeMethod("tap", withArguments: [["x":x, "y":y]]);
    }
    
    private func startTimer() {
        stopTimer()
        _timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MinesweeperGame.incrementTimer), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        if let timer = _timer {
            timer.invalidate();
            _timer = nil;
        }
    }
    
    @objc private func incrementTimer() {
        time += 1;
        if let delegate = timerDelegate {
            delegate.timeChanged(time: time);
        }
    }
}
