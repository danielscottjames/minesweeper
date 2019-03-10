//
//  MinesweeperGame.swift
//  Minesweeper
//
//  Created by Daniel James on 12/29/15.
//  Copyright © 2015 developersBliss. All rights reserved.
//

import Foundation

@objc enum GameState :Int {
    case FirstMove, Playing, Finished
}

@objc protocol MinesweeperTimerDelegate {
    func timeChanged(time :Int);
}

@objc class MinesweeperGame : NSObject {
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
