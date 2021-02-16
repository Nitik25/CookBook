import Foundation

struct MealData: Codable {
    let meals: [meals]
}

struct meals: Codable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
    let strInstructions: String
}
