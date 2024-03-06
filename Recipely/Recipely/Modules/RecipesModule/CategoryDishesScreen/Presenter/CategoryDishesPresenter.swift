// CategoryDishesPresenter.swift
// Copyright © RoadMap. All rights reserved.

import Foundation

/// Интерфейс взаимодействия с CategoryDishesPresenter
protocol CategoryDishesPresenterProtocol {
    /// Список  блюд в категории.
    var dishes: [CategoryDish] { get }
    /// Получить название категории.
    func getTitle() -> String
    /// Изменить статус сортировки по калориям.
    func changesCaloriesSortingStatus()
    /// Изменить статус сортировки по времени приготовления.
    func changesTimeSortingStatus()
    /// Соощает о нажатии на ячейку какого либо блюда
    func didTapCell(atIndex index: Int)
    /// Сообщает по индексу информацию
    func getDish(atIndex index: Int) -> DataStatus
    /// Сообщает о вью на экране
    func viewDidAppear()
    /// Возвращает массив с информацией
    func returnFilledArray()
    /// отфильтровывает таблицу
    func filterTableView(text: String)
}

/// Презентер экрана категории рецептов
final class CategoryDishesPresenter {
    // MARK: - Private Properties

    private weak var view: CategoryDishesViewProtocol?
    private weak var coordinator: RecipesCoordinatorProtocol?

    private(set) var dishes: [CategoryDish] = []
    private var initialDishes = CategoryDish.getDishes()
    private var conditionCalories = Condition.notPressed {
        willSet {
            updateDishesArray()
            view?.updateTable()
        }
    }

    private var conditionTime = Condition.notPressed {
        didSet {
            updateDishesArray()
            view?.updateTable()
        }
    }
    private var viewTitle: String
    private var hevData = false

    // MARK: - Initializers

    init(view: CategoryDishesViewProtocol, coordinator: RecipesCoordinatorProtocol, viewTitle: String) {
        self.view = view
        self.coordinator = coordinator
        self.viewTitle = viewTitle
        dishes = initialDishes
    }

    typealias AreInIncreasingOrder = (CategoryDish, CategoryDish) -> Bool
    private func createPredicatesAccordingToCurrentSelectedConditions() -> [AreInIncreasingOrder] {
        var predicatesArray: [AreInIncreasingOrder] = []
        switch conditionTime {
        case .sortingMore:
            predicatesArray.append { $0.cookingTime < $1.cookingTime }
        case .sortingSmaller:
            predicatesArray.append { $0.cookingTime > $1.cookingTime }
        default:
            break
        }

        switch conditionCalories {
        case .sortingMore:
            predicatesArray.append { $0.numberCalories < $1.numberCalories }
        case .sortingSmaller:
            predicatesArray.append { $0.numberCalories > $1.numberCalories }
        default:
            break
        }
        return predicatesArray
    }

    private func getSortedCategoryDishes(using predicates: [AreInIncreasingOrder]) -> [CategoryDish] {
        initialDishes.sorted { lhsDish, rhsDish in
            for predicate in predicates {
                if !predicate(lhsDish, rhsDish), !predicate(rhsDish, lhsDish) {
                    continue
                }
                return predicate(lhsDish, rhsDish)
            }
            return false
        }
    }

    private func updateDishesArray() {
        let predicates = createPredicatesAccordingToCurrentSelectedConditions()
        dishes = getSortedCategoryDishes(using: predicates)
    }

    private func receivedData() {
        hevData = true
        view?.updateTable()
    }
}

extension CategoryDishesPresenter: CategoryDishesPresenterProtocol {
    func viewDidAppear() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            self.receivedData()
        }
    }

    func getDish(atIndex index: Int) -> DataStatus {
        switch hevData {
        case false:
            .noData
        case true:
            .dataLoaded(dishes[index])
        }
      
    func filterTableView(text: String) {
        if text.count < 3 {
            dishes = CategoryDish.getDishes()
            view?.updateTable()
        } else {
            dishes = dishes.filter { $0.nameDish.lowercased().contains(text.lowercased()) }
            view?.updateTable()
        }
    }

    func returnFilledArray() {
        dishes = CategoryDish.getDishes()
    }

    func getTitle() -> String {
        viewTitle
    }

    func changesTimeSortingStatus() {
        conditionTime = conditionTime.next
        view?.changesTimeSortingStatus(condition: conditionTime)
    }

    func changesCaloriesSortingStatus() {
        conditionCalories = conditionCalories.next
        view?.changesCaloriesSortingStatus(condition: conditionCalories)
    }

    func didTapCell(atIndex index: Int) {
        if index == 0 {
            coordinator?.showDishDetailsScreen()
        }
    }
}
