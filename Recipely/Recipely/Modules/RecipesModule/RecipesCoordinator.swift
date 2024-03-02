// RecipesCoordinator.swift
// Copyright © RoadMap. All rights reserved.

import UIKit

/// Интерфейс взаимодействия с RecipesCoordinator
protocol RecipesCoordinatorProtocol: AnyObject {
    /// Презентует экран с блюдами из выбранной категории
    func showCategoryScreen(withTitle title: String)
    /// Презентует экран с детальным писанием рецепта
    func showRecipeDetailScreen(forRecipe: String)
}

/// Координатор модуля рецептов
final class RecipesCoordinator: BaseCoordinator {
    // MARK: - Visual Components

    private var rootController: UINavigationController

    // MARK: - Private Properties

    private var builder: Builder

    // MARK: - Initializers

    init(rootController: UINavigationController, builder: Builder) {
        self.rootController = rootController
        self.builder = builder
    }

    // MARK: - Public Methods

    override func start() {
        let recipesScreen = builder.buildRecipeDetailScreen(coordinator: self)
        rootController.setViewControllers([recipesScreen], animated: false)
    }
}

extension RecipesCoordinator: RecipesCoordinatorProtocol {
    func showCategoryScreen(withTitle title: String) {
        let categoryScreen = builder.buildCategoryScreen(coordinator: self, title: title)
        rootController.pushViewController(categoryScreen, animated: true)
    }

    func showRecipeDetailScreen(forRecipe: String) {
        let recipeDetailScreen = builder.buildRecipeDetailScreen(coordinator: self)
        rootController.pushViewController(recipeDetailScreen, animated: true)
    }
}
