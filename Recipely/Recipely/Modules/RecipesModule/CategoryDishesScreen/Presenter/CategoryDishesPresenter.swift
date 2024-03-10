// CategoryDishesPresenter.swift
// Copyright © RoadMap. All rights reserved.

import Foundation

/// Интерфейс взаимодействия с CategoryDishesPresenter
protocol CategoryDishesPresenterProtocol {
    /// Получить название категории.
    func getTitle() -> String
    /// Запрос количества блюд
    func getNumberDishes() -> Int
    /// Сообщает по индексу информацию
    func getDish(forIndex index: Int) -> ViewState
    /// Соощает о нажатии на ячейку какого либо блюда
    func didTapCell(atIndex index: Int)
    /// Сообщает о том: что вью появилас на экране
    func viewDidAppear()

    /// Сообщает о введенном пользователем заначениии поиска
    func searchBarTextChanged(to text: String)
    /// Сообщает об изменеии статуса сортировки по калориям
    func caloriesSortControlChanged(toState state: SortState)
    /// Сообщает об изменеии статуса сортировки по времени приготовления
    func timeSortControlChanged(toState state: SortState)
}

/// Презентер экрана категории рецептов
final class CategoryDishesPresenter {
    // MARK: - Types

    typealias AreDishesInIncreasingOrder = (Dish, Dish) -> Bool

    // MARK: - Private Properties

    private weak var view: CategoryDishesViewProtocol?
    private weak var coordinator: RecipesCoordinatorProtocol?

    private var viewTitle: String
    private var isDataAvalible = false
    private var dishes: [Dish] = DishesService.shared.getDishes()
//    private var initialDishes =
    private var timer: Timer?
    private var caloriesSortState = SortState.none {
        didSet {
            updateDishes()
            view?.reloadDishes()
        }
    }

    private var timeSortState = SortState.none {
        didSet {
            updateDishes()
            view?.reloadDishes()
        }
    }

    // MARK: - Initializers

    init(view: CategoryDishesViewProtocol, coordinator: RecipesCoordinatorProtocol, viewTitle: String) {
        self.view = view
        self.coordinator = coordinator
        self.viewTitle = viewTitle
    }

    // MARK: - Life Cycle

    deinit {
        print("deinit ", String(describing: self))
    }

    // MARK: - Private Methods

    private func createPredicatesAccordingToCurrentSelectedConditions() -> [AreDishesInIncreasingOrder] {
        var predicatesArray: [AreDishesInIncreasingOrder] = []
        switch timeSortState {
        case .accending:
            predicatesArray.append { $0.cookingTime < $1.cookingTime }
        case .deccending:
            predicatesArray.append { $0.cookingTime > $1.cookingTime }
        default:
            break
        }

        switch caloriesSortState {
        case .accending:
            predicatesArray.append { $0.numberCalories < $1.numberCalories }
        case .deccending:
            predicatesArray.append { $0.numberCalories > $1.numberCalories }
        default:
            break
        }
        return predicatesArray
    }

    private func getSortedCategoryDishes(using predicates: [AreDishesInIncreasingOrder]) -> [Dish] {
        dishes.sorted { lhsDish, rhsDish in
            for predicate in predicates {
                if !predicate(lhsDish, rhsDish), !predicate(rhsDish, lhsDish) {
                    continue
                }
                return predicate(lhsDish, rhsDish)
            }
            return false
        }
    }

    private func updateDishes() {
        let predicates = createPredicatesAccordingToCurrentSelectedConditions()
        dishes = getSortedCategoryDishes(using: predicates)
    }

    private func receivedData() {
        isDataAvalible = true
        view?.reloadDishes()
    }
}

extension CategoryDishesPresenter: CategoryDishesPresenterProtocol {
    func getTitle() -> String {
        viewTitle
    }

    func getNumberDishes() -> Int {
        dishes.count
    }

    func getDish(forIndex index: Int) -> ViewState {
        isDataAvalible ? .data(dishes[index]) : .loading
    }

    func didTapCell(atIndex index: Int) {
        LogAction.log("Пользователь открыл рецепт блюда \(dishes[index].name)")
        guard let dish = DishesService.shared.getDish(byId: dishes[index].id) else { return }
        coordinator?.showDishDetailsScreen(with: dish)
    }

    func viewDidAppear() {
        Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { _ in
            self.receivedData()
        }
    }

    func searchBarTextChanged(to text: String) {
        timer?.invalidate()
        isDataAvalible = (text.count < 3) ? true : false
        view?.reloadDishes()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            if text.count < 3 {
                self.dishes = DishesService.shared.getDishes()
            } else {
                self.dishes = DishesService.shared.getDishes()
                    .filter { $0.name.range(of: text, options: .caseInsensitive) != nil }
            }
            self.updateDishes()
            self.isDataAvalible = true
            self.view?.reloadDishes()
        }
    }

    func caloriesSortControlChanged(toState state: SortState) {
        caloriesSortState = state
    }

    func timeSortControlChanged(toState state: SortState) {
        timeSortState = state
    }
}
