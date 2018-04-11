//
//  OKTableViewRow.swift
//  OKTableViewLiaison
//
//  Created by Dylan Shine on 3/15/18.
//  Copyright © 2018 Dylan Shine. All rights reserved.
//

import UIKit

public protocol OKAnyTableViewRow: class {
    var height: CGFloat { get }
    var estimatedHeight: CGFloat { get }
    var editable: Bool { get }
    var movable: Bool { get }
    var editActions: [UITableViewRowAction]? { get }
    var editingStyle: UITableViewCellEditingStyle { get }
    var indentWhileEditing: Bool { get }
    var deleteConfirmationTitle: String? { get }
    var deleteRowAnimation: UITableViewRowAnimation { get }
    func registerCellType(with tableView: UITableView)
    func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    func perform(command: OKTableViewRowCommand, for cell: UITableViewCell, at indexPath: IndexPath)
}

open class OKTableViewRow<Cell: UITableViewCell, Model>: OKAnyTableViewRow {
    
    public let model: Model
    public var editingStyle: UITableViewCellEditingStyle
    public var movable: Bool
    public var editActions: [UITableViewRowAction]?
    public var indentWhileEditing: Bool
    public var deleteConfirmationTitle: String?
    public var deleteRowAnimation: UITableViewRowAnimation
    public var registrationType: OKTableViewRegistrationType
    
    private var commands = [OKTableViewRowCommand: (Cell, Model, IndexPath) -> Void]()
    private var heights = [OKTableViewHeightType: (Model) -> CGFloat]()
    
    public init(_ model: Model,
                editingStyle: UITableViewCellEditingStyle = .none,
                movable: Bool = false,
                editActions: [UITableViewRowAction]? = nil,
                indentWhileEditing: Bool = false,
                deleteConfirmationTitle: String? = nil,
                deleteRowAnimation: UITableViewRowAnimation = .automatic,
                registrationType: OKTableViewRegistrationType = .defaultClassRegistration(for: Cell.self)) {
        self.model = model
        self.editingStyle = editingStyle
        self.movable = movable
        self.editActions = editActions
        self.indentWhileEditing = indentWhileEditing
        self.deleteConfirmationTitle = deleteConfirmationTitle
        self.deleteRowAnimation = deleteRowAnimation
        self.registrationType = registrationType
    }
    
    // MARK: - Cell
    public func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueCell(with: tableView)
        commands[.configuration]?(cell, model, indexPath)
        return cell
    }
    
    public func registerCellType(with tableView: UITableView) {
        switch registrationType {
        case let .class(identifier):
            tableView.register(Cell.self, forCellReuseIdentifier: identifier)
        case let .nib(nib, identifier):
            tableView.register(nib, forCellReuseIdentifier: identifier)
        }
    }
    
    // MARK: - Commands
    public func perform(command: OKTableViewRowCommand, for cell: UITableViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? Cell else {
            return
        }
        
        commands[command]?(cell, model, indexPath)
    }
    
    public func set(command: OKTableViewRowCommand, with closure: ((Cell, Model, IndexPath) -> Void)?) {
        commands[command] = closure
    }
    
    public func remove(command: OKTableViewRowCommand) {
        commands[command] = nil
    }
    
    public func set(height: OKTableViewHeightType, with closure: ((Model) -> CGFloat)?) {
        heights[height] = closure
    }
    
    public func set(height: OKTableViewHeightType, value: CGFloat) {
        let closure: ((Model) -> CGFloat)? = { _ -> CGFloat in return value }
        heights[height] = closure
    }
    
    // MARK: - Computed Properties
    public var height: CGFloat {
        return calculate(height: .height)
    }
    
    public var estimatedHeight: CGFloat {
        return calculate(height: .estimatedHeight)
    }
    
    public var reuseIdentifier: String {
        return registrationType.identifier
    }
    
    public var editable: Bool {
        return editingStyle != .none || editActions?.isEmpty == false
    }

    // MARK: - Private
    private func dequeueCell(with tableView: UITableView) -> Cell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? Cell else {
            fatalError("Failed to dequeue cell of type \(Cell.self).")
        }
        
        return cell
    }
    
    private func calculate(height: OKTableViewHeightType) -> CGFloat {
        return heights[height]?(model) ?? UITableViewAutomaticDimension
    }
}

public extension OKTableViewRow where Model == Void {
    
    public convenience init(editingStyle: UITableViewCellEditingStyle = .none,
                            movable: Bool = false,
                            editActions: [UITableViewRowAction]? = nil,
                            indentWhileEditing: Bool = false,
                            deleteConfirmationTitle: String? = nil,
                            deleteRowAnimation: UITableViewRowAnimation = .automatic,
                            registrationType: OKTableViewRegistrationType = .defaultClassRegistration(for: Cell.self)) {
        
        self.init((),
                  editingStyle: editingStyle,
                  movable: movable,
                  editActions: editActions,
                  indentWhileEditing: indentWhileEditing,
                  deleteConfirmationTitle: deleteConfirmationTitle,
                  deleteRowAnimation: deleteRowAnimation,
                  registrationType: registrationType)
    }
}
