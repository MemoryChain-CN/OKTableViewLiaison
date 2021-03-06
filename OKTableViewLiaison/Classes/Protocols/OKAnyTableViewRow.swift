//
//  OKAnyTableViewRow.swift
//  OKTableViewLiaison
//
//  Created by Dylan Shine on 5/24/18.
//

import UIKit

public protocol OKAnyTableViewRow: OKTableViewContent {
    var editable: Bool { get }
    var movable: Bool { get }
    var editActions: [UITableViewRowAction]? { get }
    var editingStyle: UITableViewCellEditingStyle { get }
    var indentWhileEditing: Bool { get }
    var deleteConfirmationTitle: String? { get }
    var deleteRowAnimation: UITableViewRowAnimation { get }
    func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    func perform(command: OKTableViewRowCommand, for cell: UITableViewCell, at indexPath: IndexPath)
    func perform(prefetchCommand: OKTableViewPrefetchCommand, for indexPath: IndexPath)
}
