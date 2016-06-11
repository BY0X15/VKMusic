//
//  PlayerManager.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 03.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

import UIKit
import AVFoundation

/// Менеджер воспроизведения
class PlayerManager {
    
    private struct Static {
        static var onceToken: dispatch_once_t = 0 // Ключ идентифицирующий жизненынный цикл приложения
        static var instance: PlayerManager? = nil
    }
    
    class var sharedInstance: PlayerManager {
        dispatch_once(&Static.onceToken) { // Для указанного токена выполняет блок кода только один раз за время жизни приложения
            Static.instance = PlayerManager()
        }
        
        return Static.instance!
    }

    private init() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        miniPlayerViewController = storyboard.instantiateViewControllerWithIdentifier("MiniPlayerViewController") as! MiniPlayerViewController
        
        player.delegate = self
    }
    
    
    // MARK: Работа с делегатами
    
    /// Делегаты менеджера плеера
    private var delegates = [PlayerManagerDelegate]()
    
    /// Добавление нового делегата
    func addDelegate(delegate: PlayerManagerDelegate) {
        if let _ = delegates.indexOf({ $0 === delegate}) {
            return
        }
        
        delegates.append(delegate)
    }
    
    /// Удаление делегата
    func deleteDelegate(delegate: PlayerManagerDelegate) {
        if let index = delegates.indexOf({ $0 === delegate}) {
            delegates.removeAtIndex(index)
        }
    }
    
    
    // MARK: Мини-плеер
    
    /// Контроллер с мини-плеером
    let miniPlayerViewController: MiniPlayerViewController!
    
    /// Скрыть мини-плеер
    func hideMiniPlayerAnimated(animated: Bool) {
        miniPlayerViewController.hideMiniPlayerAnimated(animated)
    }
    
    /// Отобразить мини-плеер
    func showMiniPlayerAnimated(animated: Bool) {
        miniPlayerViewController.showMiniPlayerAnimated(animated)
    }
    
    
    // MARK: Свойства
    
    /// Плеер
    var player = Player()
    
    /// Идентификатор плейлиста, воспроизводимого сейчас
    var playlistIdentifier: String?
    
    /// Воспроизводится ли музыка
    var isPlaying = false
    /// Активна ли пауза (активируется при нажатии по кнопке "Пауза")
    var isPauseActive = false
    /// Название исполняемой аудиозаписи
    var trackTitle: String?
    /// Имя исполнителя исполняемой аудиозаписи
    var artist: String?
    /// Длина аудиозаписи
    var duration = 0.0
    /// Текущее время аудиозаписи
    var currentTime = 0.0 {
        didSet {
            if currentTime < 0 {
                currentTime = 0
            }
        }
    }
    /// Прогресс воспроизведения
    var progress: Float {
        return Float(currentTime / duration)
    }
    
    /// Отображать ли музыку в статусе
    var isShareToStatus = false
    /// Перемешивать ли плейлист
    var isShuffle = false
    /// Тип повторения плейлиста
    var repeatType = PlayerRepeatType.No
    
    
    // MARK: Начало воспроизведения
    
    /// Воспроизвести аудиозапись по указанному индексу, в указанном плейлисте с указанным идентификатором
    func playItemWithIndex(index: Int , inOnlinePlaylist playlist: [Track], withPlaylistIdentifier playlistIdentifier: String) {
        isPauseActive = false
        
        if let _playlistIdentifier = self.playlistIdentifier where _playlistIdentifier == playlistIdentifier {
            player.playAtIndex(index)
        } else {
            self.playlistIdentifier = playlistIdentifier
            
            var playerItems = [PlayerItem]()
            
            for track in playlist {
                playerItems.append(PlayerItem(onlineTrack: track))
            }
            
            player.clear()
            player.assignQueuedItems(playerItems)
            player.playAtIndex(index)
        }
    }
    
    
    // MARK: Управление воспроизведением
    
    /// Пользователь начал перемотку аудиозаписи
    func sliderEditingDidBegin() {
        if isPlaying {
            player.pause()
        }
    }
    
    /// Пользователь закончил перемотку аудиозаписи
    func sliderEditingDidEndWithSecond(second: Int) {
        player.seekToSecond(second, shouldPlay: !isPauseActive)
    }
    
    /// Пользователь переключил на предыдущую аудиозапись
    func previousTapped() {
        player.playPrevious()
    }
    
    /// Нажата кнопка "Play" на одном из контроллеров
    func playTapped() {
        player.play()
        
        isPauseActive = false
    }
    
    /// Нажата кнопка "Пауза" на одном из контроллеров
    func pauseTapped() {
        player.pause()
        
        isPauseActive = true
    }
    
    /// Пользователь переключил на следующую аудиозапись
    func nextTapped() {
        player.playNext()
    }
    
    /// Была нажата кнопка "Отправлять музыку в статус"
    func shareToStatusButtonTapped() {
        isShareToStatus = !isShareToStatus
        
        delegates.forEach { delegate in
            delegate.playerManagerShareToStatusSettingChangedTo(isShareToStatus)
        }
    }
    
    /// Была нажата кнопка "Повторять"
    func repeatButtonTapped() {
        nextRepeatType()
        
        delegates.forEach { delegate in
            delegate.playerManagerRepeatTypeDidChange(repeatType)
        }
    }
    
    /// Была нажата кнопка "Перемешать"
    func shuffleButtonTapped() {
        isShuffle = !isShuffle
        
        delegates.forEach { delegate in
            delegate.playerManagerShuffleSettingChangedTo(isShuffle)
        }
    }
    
    
    // MARK: Помощники
    
    /// Переключение типа повторения
    func nextRepeatType() {
        switch repeatType {
        case .No:
            repeatType = .All
        case .All:
            repeatType = .One
        case .One:
            repeatType = .No
        }
    }
    
}


// MARK: PlayerDelegate

extension PlayerManager: PlayerDelegate {
    
    // Плеер изменил состояние
    func playerStateDidChange(player: Player) {
        isPlaying = player.state == .Playing
        
        delegates.forEach { delegate in
            delegate.playerManagerGetNewState(player.state)
        }
    }
    
    // Плеер изменил прогресс воспроизведения
    func playerPlaybackProgressDidChange(player: Player) {
        currentTime = player.currentItem!.currentTime!
        
        delegates.forEach { delegate in
            delegate.playerManagerCurrentItemGetNewTimerProgress(progress)
        }
    }
    
    // Плеер изменил воспроизводимый элемент
    func playerCurrentItemDidChange(player: Player) {
        trackTitle = player.currentItem!.title
        artist = player.currentItem!.artist
        duration = player.currentItem!.duration!
        
        delegates.forEach { delegate in
            delegate.playerManagerGetNewItem(player.currentItem!)
        }
    }
    
}