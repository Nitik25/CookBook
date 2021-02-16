import UIKit

protocol MealManagerDelegate {
    func didFetchMeal(_ mealManager: MealManager, meal: MealModel)
    func didFetchMealImage(_ mealManager: MealManager, mealImage: UIImage)
    func didFailWithError(error: Error)
}

struct MealManager {
    
    var delegate: MealManagerDelegate?
    
    func fetchRandomMeal() {
        performRequest(with: K.kRandomMealURL)
    }
    
    func fetchMealRecipe(for name: String) {
        performRequest(with: K.kMealWithNameURL + name)
    }
    
    private func performRequest(with URLString: String) {
        if let URL = URL(string: URLString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: URL) { data, response, error in
                if error != nil {
                    DispatchQueue.main.async {
                        self.delegate?.didFailWithError(error: error!)
                    }
                    return
                }
                if let data = data, let meal = self.parseJSON(data) {
                    DispatchQueue.main.async {
                        self.delegate?.didFetchMeal(self, meal: meal)
                    }
                }
            }
            task.resume()
        }
    }
    
    private func parseJSON(_ mealData: Data) -> MealModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(MealData.self, from: mealData)
            let meal = decodedData.meals[0]
            let id = Int(meal.idMeal) ?? 0
            let name = meal.strMeal
            let imageURL = meal.strMealThumb
            let instructions = meal.strInstructions
            
            // Create meal model.
            let mealModel = MealModel(mealId: id, mealName: name, recipeInstructions: instructions)
            
            performImageRequest(with: imageURL)
            
            return mealModel
        } catch {
            DispatchQueue.main.async {
                delegate?.didFailWithError(error: error)
            }
            
            return nil
        }
    }
    
    private func performImageRequest(with URLString: String) {
        if let URL = URL(string: URLString),
           let data = try? Data(contentsOf: URL) {
            let image = UIImage(data: data) ?? #imageLiteral(resourceName: "Food CookBook")
            DispatchQueue.main.async {
                self.delegate?.didFetchMealImage(self, mealImage: image)
            }
        }
    }
}
