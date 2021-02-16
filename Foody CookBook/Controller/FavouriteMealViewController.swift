import UIKit
import CoreData

class FavouriteMealViewController: UIViewController {
    @IBOutlet weak var favouriteMealTableView: UITableView!
    
    var favouriteMeals = [FavouriteMeal]()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMealsData()
        favouriteMealTableView.dataSource = self
    }
    
    private func loadMealsData() {
        do {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let request: NSFetchRequest<FavouriteMeal> = FavouriteMeal.fetchRequest()
            favouriteMeals = try context.fetch(request)
        } catch {
            print("Could not fetch saved meals \(error)")
        }
    }
}

// MARK: - UITableViewDataSource
extension FavouriteMealViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteMeals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.kMealCellReuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = favouriteMeals[indexPath.row].name
        return cell
    }
}
