import UIKit

class SearchRecipeViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var addToFavouriteButton: UIButton!
    @IBOutlet weak var dishImage: UIImageView!
    @IBOutlet weak var recipeLabel: UILabel!
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityProgressView: UIView!
    @IBOutlet weak var activityProgressIndicator: UIActivityIndicatorView!
    
    var mealManager = MealManager()
    var mealID = 0
    var mealName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        
        startProgressAnimation()
        
        mealManager.delegate = self
        mealManager.fetchRandomMeal()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Action
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    @IBAction func addToFavouritesTapped(_ sender: UIButton) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let meal = FavouriteMeal(context: context)
        meal.mealID = Int64(mealID)
        meal.name = mealName
        
        do {
            try context.save()
        } catch {
            print("Could not persist the favourite meal")
        }
    }
    
    // MARK: - Progress Indicator
    
    private func startProgressAnimation() {
        activityProgressView.isHidden = false
        activityProgressIndicator.startAnimating()
        
    }
    
    private func stopProgressAnimation() {
        activityProgressIndicator.stopAnimating()
        activityProgressView.isHidden = true
    }
}

// MARK: - UITextFieldDelegate

extension SearchRecipeViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if searchTextField.text != "" {
            return true
        } else {
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let mealName = searchTextField.text {
            startProgressAnimation()
            mealManager.fetchMealRecipe(for: mealName)
        }
        searchTextField.text = ""
    }
}

// MARK: - MealManagerDelegate

extension SearchRecipeViewController: MealManagerDelegate {
    func didFetchMeal(_ mealManager: MealManager, meal: MealModel) {
        mealID = meal.mealId
        mealName = meal.mealName
        
        addToFavouriteButton.isHidden = false
        dishNameLabel.text = mealName
        recipeLabel.text =  meal.recipeInstructions
        stopProgressAnimation()
    }
    
    func didFetchMealImage(_ mealManager: MealManager, mealImage: UIImage) {
        dishImage.image = mealImage
    }
    
    func didFailWithError(error: Error) {
        dishNameLabel.text = K.kErrorLabel
        recipeLabel.text = K.kErrorInfo
        addToFavouriteButton.isHidden = true
        dishImage.image = #imageLiteral(resourceName: "Food CookBook")
        stopProgressAnimation()
    }
}
