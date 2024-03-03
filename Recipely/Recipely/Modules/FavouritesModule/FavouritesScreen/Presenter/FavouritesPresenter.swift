// FavouritesPresenter.swift
// Copyright © RoadMap. All rights reserved.

import UIKit

/// Интерфейс взаимодействия с FavouritesPresenter
protocol FavouritesPresenterProtocol: AnyObject {
    /// Возвращает массив секций рецептов для отображения в пользовательском интерфейсе.
    func getDish(forIndex index: Int) -> CategoryRecipes
    /// Возвращает количество подразделов рецептов
    func getNumberOfDishes() -> Int
    /// удаляет рецепт из избранного.
    func removeItem(forIndex index: Int)
    /// проверяет пустой ли массив
    func checkEmptiness()
}

/// Презентер экрана списка сохраненных рецептов
final class FavouritesPresenter {
    // MARK: - Private Properties

    private weak var coordinator: FavouritesCoordinatorProtocol?
    private weak var view: FavouritesViewProtocol?
    private var favouriteDishes = CategoryRecipes.makeRecipes()

    // MARK: - Initializers

    init(view: FavouritesView, coordinator: FavouritesCoordinatorProtocol) {
        self.view = view
        self.coordinator = coordinator
    }
}

extension FavouritesPresenter: FavouritesPresenterProtocol {
    func checkEmptiness() {
//        if favouriteDishes.isEmpty {
//            view?.setPlaceholderViewIsHidden(to: favo)
//        }
        view?.setPlaceholderViewIsHidden(to: !favouriteDishes.isEmpty)
    }

    func removeItem(forIndex index: Int) {
        favouriteDishes.remove(at: index)
    }

    func getNumberOfDishes() -> Int {
        favouriteDishes.count
    }

    func getDish(forIndex index: Int) -> CategoryRecipes {
        favouriteDishes[index]
    }
}
