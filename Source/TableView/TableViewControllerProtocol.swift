//
//  TableViewControllerProtocol.swift
//  AirCollection
//
//  Created by Lysytsia Yurii on 27.07.2020.
//  Copyright © 2020 Developer Lysytsia. All rights reserved.
//

import struct Foundation.IndexPath
import struct Foundation.IndexSet
import struct CoreGraphics.CGPoint
import class UIKit.UIView
import class UIKit.UITableView
import class UIKit.UITableViewCell
import protocol UIKit.UIScrollViewDelegate
import func Foundation.objc_getAssociatedObject
import func Foundation.objc_setAssociatedObject

public protocol TableViewControllerProtocol: class {
    
    /// Return an instanse of the table view. This table view will be use by presenter
    var tableViewSource: UITableView { get }
    
    /// Return an instanse of the table view presenter
    var tableViewPresenter: TableViewPresenterProtocol { get }
    
    /// Configure `UITableViewDataSource` and `UITableViewDelegate` for specific table view and presenter. Also automatically add `TableViewDelegate` to current view controller if implemented.
    /// - Parameter configurator: Use this block to set up the table view. You should register table view cell, headers and footer is this case
    func configureTableView(configurator: (UITableView) -> Void)
    
    /// Reloads the rows and sections of the table view
    func reloadTableView()
    
    /// Begin update table view data and table view rows
    /// - Parameters:
    ///   - updates: Use this block to call update methods for table view. You should call `reloadTableViewRows(at:with:)`, `deleteTableViewRows(at:with:)`, `insertTableViewRows(at:with:)`
    ///   - completion: A completion handler block to execute when all of the operations are finished
    func updateTableView(updates: () -> Void, completion: ((Bool) -> Void)?)
    
    /// Update table view rows for specific rows and section.
    /// - Parameters:
    ///   - deletions: Rows that will be delete
    ///   - insertions: Rows that will be insert
    ///   - modifications: Rows that will be reload
    ///   - section: Section where this rows will updated. For exaple for `deletions = [0]` and `section = 1` will removed row at `IndexPath(row: 0, section: 1)`
    func updateTableView(deletions: [Int], insertions: [Int], modifications: [Int], forSection section: Int, with animation: UITableView.RowAnimation, completion: ((Bool) -> Void)?)
    
    /// Reloads the specified rows using a given animation effect.
    func reloadTableViewRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
    
    /// Deletes the rows specified by an array of index paths, with an option to animate the deletion
    func deleteTableViewRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
    
    /// Inserts rows in the table view at the locations identified by an array of index paths, with an option to animate the insertion
    func insertTableViewRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
    
    /// Moves the row at a specified location to a destination location
    func moveTableViewRow(at indexPath: IndexPath, to newIndexPath: IndexPath)
    
    /// Selects a row in the table view identified by index path, optionally scrolling the row to a location in the table view
    func selectTableViewRow(at indexPath: IndexPath, animated: Bool, scrollPosition: UITableView.ScrollPosition)
    
    /// Deselects a given row identified by index path, with an option to animate the deselection.
    func deselectTableViewRow(at indexPath: IndexPath, animated: Bool)
    
    /// Make a row input view in the table view identified by index path the first responder in its window at.
    func becomeTableViewRowFirstResponder(at indexPath: IndexPath)
    
    /// Notifies a row input view in the table view identified by index path that it has been asked to relinquish its status as first responder in its window.
    func resignTableViewRowFirstResponder(at indexPath: IndexPath)
    
    /// Reloads the specified sections using a given animation effect
    func reloadTableViewSections(_ sections: [Int], with animation: UITableView.RowAnimation)
    
    /// Deletes one or more sections in the table view, with an option to animate the deletion
    func deleteTableViewSections(_ sections: [Int], with animation: UITableView.RowAnimation)
    
    /// Inserts one or more sections in the table view, with an option to animate the insertion
    func insertTableViewSections(_ sections: [Int], with animation: UITableView.RowAnimation)
    
    /// Moves a section to a new location in the table view
    func moveTableViewSection(from section: Int, to newSection: Int)
    
    /// Scrolls through the table view until a row identified by index path is at a particular location on the screen
    func scrollTableViewToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool)
    
    /// Scrolls the table view so that the selected row nearest to a specified position in the table view is at that position
    func scrollTableViewToNearestSelectedRow(at scrollPosition: UITableView.ScrollPosition, animated: Bool)
    
    /// Call `configureCell(_:for)` method for cell at specified index path of the table view
    func reconfigureTableViewCellForRow(at indexPath: IndexPath)
    
    /// Returns an index path identifying the subview
    func indexPathForRow(with view: UIView) -> IndexPath?
    
}

public extension TableViewControllerProtocol {
    
    // MARK: Configure
    func configureTableView(configurator: (UITableView) -> Void) {
        self.tableViewSource.dataSource = self.tableViewData
        self.tableViewSource.delegate = self.tableViewData
        if let delegate = self as? TableViewDelegate {
            // Forward available table view delegates to current view controller.
            self.tableViewData.tableViewDelegate = delegate
        }
        configurator(self.tableViewSource)
    }
    
    // MARK: Reload
    func reloadTableView() {
        self.tableViewData.reloadAll()
        self.tableViewSource.reloadData()
    }
    
    // MARK: Update
    func updateTableView(updates: () -> Void, completion: ((Bool) -> Void)?) {
        self.tableViewSource.performBatchUpdates({
            updates()
        }, completion: { (finished) in
            completion?(finished)
        })
    }
    
    func updateTableView(updates: () -> Void) {
        self.updateTableView(updates: updates, completion: nil)
    }
    
    func updateTableView(deletions: [Int], insertions: [Int], modifications: [Int], forSection section: Int, with animation: UITableView.RowAnimation, completion: ((Bool) -> Void)?) {
        if deletions.isEmpty, insertions.isEmpty, modifications.isEmpty {
            assertionFailure("\(#function) deletions, insertions or modifications can't be empty. One of them must contains element")
            return
        }
        self.updateTableView(updates: {
            if !deletions.isEmpty {
                let indexPaths = deletions.map { IndexPath(row: $0, section: section) }
                self.deleteTableViewRows(at: indexPaths, with: animation)
            }
            if !insertions.isEmpty {
                let indexPaths = insertions.map { IndexPath(row: $0, section: section) }
                self.insertTableViewRows(at: indexPaths, with: animation)
            }
            if !modifications.isEmpty {
                let indexPaths = modifications.map { IndexPath(row: $0, section: section) }
                self.reloadTableViewRows(at: indexPaths, with: animation)
            }
        }, completion: completion)
    }
    
    func updateTableView(deletions: [Int], insertions: [Int], modifications: [Int], forSection section: Int, completion: ((Bool) -> Void)? = nil) {
        self.updateTableView(deletions: deletions, insertions: insertions, modifications: modifications, forSection: section, with: .automatic, completion: completion)
    }
    
    // MARK: Rows
    func reloadTableViewRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        self.tableViewData.reloadRows(at: indexPaths)
        self.tableViewSource.reloadRows(at: indexPaths, with: animation)
    }
    
    func reloadTableViewRows(at indexPaths: [IndexPath]) {
        self.reloadTableViewRows(at: indexPaths, with: .automatic)
    }
    
    func deleteTableViewRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        self.tableViewData.removeRows(at: indexPaths)
        self.tableViewSource.deleteRows(at: indexPaths, with: animation)
    }
    
    func deleteTableViewRows(at indexPaths: [IndexPath]) {
        self.deleteTableViewRows(at: indexPaths, with: .automatic)
    }
    
    func insertTableViewRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        self.tableViewData.insertRows(at: indexPaths)
        self.tableViewSource.insertRows(at: indexPaths, with: animation)
    }
    
    func insertTableViewRows(at indexPaths: [IndexPath]) {
        self.insertTableViewRows(at: indexPaths, with: .automatic)
    }
    
    func moveTableViewRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        self.tableViewData.moveRow(from: indexPath, to: newIndexPath)
        self.tableViewSource.moveRow(at: indexPath, to: newIndexPath)
    }
    
    func selectTableViewRow(at indexPath: IndexPath, animated: Bool, scrollPosition: UITableView.ScrollPosition) {
        self.tableViewSource.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    func deselectTableViewRow(at indexPath: IndexPath, animated: Bool) {
        self.tableViewSource.deselectRow(at: indexPath, animated: animated)
    }
    
    func becomeTableViewRowFirstResponder(at indexPath: IndexPath) {
        guard let cell = self.tableViewSource.cellForRow(at: indexPath) as? InputConfigurableView else {
            return
        }
        cell.becomeInputViewFirstResponder()
    }
    
    func resignTableViewRowFirstResponder(at indexPath: IndexPath) {
        guard let cell = self.tableViewSource.cellForRow(at: indexPath) as? InputConfigurableView else {
            return
        }
        cell.resignInputViewFirstResponder()
    }
    
    // MARK: Sections
    func reloadTableViewSections(_ sections: [Int], with animation: UITableView.RowAnimation) {
        self.tableViewData.reloadSections(sections)
        let indexSet = IndexSet(sections)
        self.tableViewSource.reloadSections(indexSet, with: animation)
    }
    
    func reloadTableViewSection(_ section: Int) {
        self.reloadTableViewSections([section], with: .automatic)
    }
    
    func deleteTableViewSections(_ sections: [Int], with animation: UITableView.RowAnimation) {
        self.tableViewData.removeSections(sections)
        let indexSet = IndexSet(sections)
        self.tableViewSource.deleteSections(indexSet, with: animation)
    }
    
    func deleteTableViewSections(_ sections: [Int]) {
        self.deleteTableViewSections(sections, with: .automatic)
    }
    
    func insertTableViewSections(_ sections: [Int], with animation: UITableView.RowAnimation) {
        self.tableViewData.insertSections(sections)
        let indexSet = IndexSet(sections)
        self.tableViewSource.insertSections(indexSet, with: animation)
    }
    
    func insertTableViewSections(_ sections: [Int]) {
        self.insertTableViewSections(sections, with: .automatic)
    }
    
    func moveTableViewSection(from section: Int, to newSection: Int) {
        self.tableViewData.moveSection(from: section, to: newSection)
        self.tableViewSource.moveSection(section, toSection: newSection)
    }

    // MARK: Scroll
    func scrollTableViewToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        self.tableViewSource.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    func scrollTableViewToNearestSelectedRow(at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        self.tableViewSource.scrollToNearestSelectedRow(at: scrollPosition, animated: animated)
    }
    
    // MARK: Configuration
    func reconfigureTableViewCellForRow(at indexPath: IndexPath) {
        guard let cell = self.tableViewSource.cellForRow(at: indexPath) else {
            return
        }
        self.tableViewData.configureCell(cell, for: indexPath)
    }

    func indexPathForRow(with view: UIView) -> IndexPath? {
        let rect = view.convert(view.bounds, to: self.tableViewSource)
        return self.tableViewSource.indexPathsForRows(in: rect)?.first
    }
    
}

// MARK: - TableViewData
fileprivate var tableViewDataKey: String = "TableViewControllerProtocol.tableViewData"
fileprivate extension TableViewControllerProtocol {
    
    /// Get associated `TableViewData` object with this table view controller. Will create new one if associated object is nil
    var tableViewData: TableViewData {
        if let data = objc_getAssociatedObject(self, &tableViewDataKey) as? TableViewData {
            return data
        } else {
            // Create new `tableViewData` model
            let tableViewData = TableViewData(input: self, output: self.tableViewPresenter)
            objc_setAssociatedObject(self, &tableViewDataKey, tableViewData, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return tableViewData
        }
    }
    
}

