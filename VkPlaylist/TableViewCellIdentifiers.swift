//
//  TableViewCellIdentifiers.swift
//  VkPlaylist
//
//  Created by Илья Халяпин on 09.05.16.
//  Copyright © 2016 Ilya Khalyapin. All rights reserved.
//

/// Идентификаторы ячеек

struct TableViewCellIdentifiers {
    static let noAuthorizedCell = "NoAuthorizedCell" // Ячейка с сообщением об отсутствии авторизации
    static let networkErrorCell = "NetworkErrorCell" // Ячейка с сообщением об ошибке при подключении к интернету
    static let accessErrorCell = "AccessErrorCell" // Ячейка с сообщением об ошибке доступа
    static let nothingFoundCell = "NothingFoundCell" // Ячейка с сообщением "ничего не найдено"
    static let loadingCell = "LoadingCell" // Ячейка с сообщением о загрузке данных
    static let audioCell = "AudioCell" // Ячейка для вывода аудиозаписи
    static let playlistCell = "PlaylistCell" // Ячейка для вывода плейлиста
    static let friendCell = "FriendCell" // Ячейка для вывода друга
    static let groupCell = "GroupCell" // Ячейка для вывода группы
    static let numberOfRowsCell = "NumberOfRowsCell" // Ячейка для вывода количества строк в таблице
}