//
//  Path.swift
//  FileKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-2016 Nikolai Vazquez
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  swiftlint:disable file_length
//

import Foundation

/// A representation of a filesystem path.
///
/// An Path instance lets you manage files in a much easier way.
///
public struct Path: StringLiteralConvertible, RawRepresentable, Hashable, Indexable {

    // MARK: - Static Methods and Properties

    /// The standard separator for path components.
    public static let separator = "/"

    /// The root path.
    public static let Root = Path(separator)

    /// The path of the program's current working directory.
    public static var Current: Path {
        get {
            return Path(NSFileManager.defaultManager().currentDirectoryPath)
        }
        set {
            NSFileManager.defaultManager().changeCurrentDirectoryPath(newValue._safeRawValue)
        }
    }

    /// The paths of the mounted volumes available.
    public static func volumes(options: NSVolumeEnumerationOptions = []) -> [Path] {
        let volumes = NSFileManager.defaultManager().mountedVolumeURLsIncludingResourceValuesForKeys(nil,
            options: options)
        return (volumes ?? []).flatMap { Path(url: $0) }
    }

    // MARK: - Properties

    private var _fmWraper = _FMWrapper()

    private class _FMWrapper {
        let unsafeFileManager = NSFileManager()
        weak var delegate: NSFileManagerDelegate?
        /// Safe way to use fileManager
        var fileManager: NSFileManager {
            get {
//                if delegate == nil {
//                    print("\n\nDelegate is nil\n\n")
//                }
                unsafeFileManager.delegate = delegate
                return unsafeFileManager
            }
        }
    }

    /// The delegate for the file manager used by the path.
    ///
    /// **Note:** no strong reference stored in path, so make sure keep the delegate or it will be `nil`
    public var fileManagerDelegate: NSFileManagerDelegate? {
        get {
            return _fmWraper.delegate
        }
        set {
            if !isUniquelyReferencedNonObjC(&_fmWraper) {
                _fmWraper = _FMWrapper()
            }
            _fmWraper.delegate = newValue
        }
    }

    /// The stored path string value.
    public private(set) var rawValue: String

    /// The non-empty path string value. For internal use only.
    ///
    /// Some NSAPI may throw `NSInvalidArgumentException` when path is `""`, which can't catch in swift
    /// and cause crash
    internal var _safeRawValue: String {
        return rawValue.isEmpty ? "." : rawValue
    }

    /// The standardized path string value
    public var standardRawValue: String {
        get {
            return (self.rawValue as NSString).stringByStandardizingPath
        }
    }

    /// The standardized path string value without expanding tilde
    public var standardRawValueWithTilde: String {
        get {
            let comps = components
            if comps.isEmpty {
                return ""
            } else {
                return self[comps.count - 1].rawValue
            }
        }
    }

    /// The components of the path.
    ///
    /// Return [] if path is `.` or `""`
    public var components: [Path] {
        if rawValue == "" || rawValue == "." {
            return []
        }
        if isAbsolute {
            return (absolute.rawValue as NSString).pathComponents.enumerate().flatMap {
                (($0 == 0 || $1 != "/") && $1 != ".") ? Path($1) : nil
            }
        } else {
            let comps = (self.rawValue as NSString).pathComponents.enumerate()
            // remove extraneous `/` and `.`
            let cleanComps = comps.flatMap {
                (($0 == 0 || $1 != "/") && $1 != ".") ? Path($1) : nil
            }
            return _cleanComponents(cleanComps)
        }
    }

    /// resolving `..` if possible
    private func _cleanComponents(comps: [Path]) -> [Path] {
        var isContinue = false
        let count = comps.count
        let cleanComps: [Path] = comps.enumerate().flatMap {
            if ($1.rawValue != ".." && $0 < count - 1 && comps[$0 + 1].rawValue == "..") || ($1.rawValue == ".." && $0 > 0 && comps[$0 - 1].rawValue != "..") {
                isContinue = true
                return nil
            } else {
                return $1
            }
        }
        return isContinue ? _cleanComponents(cleanComps) : cleanComps
    }

    /// The name of the file at `self`.
    public var fileName: String {
        return self.absolute.components.last?.rawValue ?? ""
    }

    /// A new path created by removing extraneous components from the path.
    public var standardized: Path {
        return Path((self.rawValue as NSString).stringByStandardizingPath)
    }

    /// The standardized path string value without expanding tilde
    public var standardWithTilde: Path {
        get {
            let comps = components
            if comps.isEmpty {
                return Path("")
            } else {
                return self[comps.count - 1]
            }
        }
    }

    /// A new path created by resolving all symlinks and standardizing the path.
    public var resolved: Path {
        return Path((self.rawValue as NSString).stringByResolvingSymlinksInPath)
    }

    /// A new path created by making the path absolute.
    ///
    /// - Returns: If `self` begins with "/", then the standardized path is
    ///            returned. Otherwise, the path is assumed to be relative to
    ///            the current working directory and the standardized version of
    ///            the path added to the current working directory is returned.
    ///
    public var absolute: Path {
        return self.isAbsolute
            ? self.standardized
            : (Path.Current + self).standardized
    }

    /// Returns `true` if the path is equal to "/".
    public var isRoot: Bool {
        return resolved.rawValue == Path.separator
    }

    /// Returns `true` if the path begins with "/".
    public var isAbsolute: Bool {
        return rawValue.hasPrefix(Path.separator)
    }

    /// Returns `true` if the path does not begin with "/".
    public var isRelative: Bool {
        return !isAbsolute
    }

    /// Returns `true` if a file or directory exists at the path.
    ///
    /// this method does follow links.
    public var exists: Bool {
        return _fmWraper.fileManager.fileExistsAtPath(_safeRawValue)
    }

    /// Returns `true` if a file or directory or symbolic link exists at the path
    ///
    /// this method does **not** follow links.
//    public var existsOrLink: Bool {
//        return self.isSymbolicLink || _fmWraper.fileManager.fileExistsAtPath(_safeRawValue)
//    }

    /// Returns `true` if the current process has write privileges for the file
    /// at the path.
    ///
    /// this method does follow links.
    public var isWritable: Bool {
        return _fmWraper.fileManager.isWritableFileAtPath(_safeRawValue)
    }

    /// Returns `true` if the current process has read privileges for the file
    /// at the path.
    ///
    /// this method does follow links.
    public var isReadable: Bool {
        return _fmWraper.fileManager.isReadableFileAtPath(_safeRawValue)
    }

    /// Returns `true` if the current process has execute privileges for the
    /// file at the path.
    ///
    /// this method does follow links.
    public var isExecutable: Bool {
        return  _fmWraper.fileManager.isExecutableFileAtPath(_safeRawValue)
    }

    /// Returns `true` if the current process has delete privileges for the file
    /// at the path.
    ///
    /// this method does **not** follow links.
    public var isDeletable: Bool {
        return  _fmWraper.fileManager.isDeletableFileAtPath(_safeRawValue)
    }

    /// Returns `true` if the path points to a directory.
    ///
    /// this method does follow links.
    public var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        return _fmWraper.fileManager.fileExistsAtPath(_safeRawValue, isDirectory: &isDirectory)
            && isDirectory
    }

    /// Returns `true` if the path is a directory file.
    ///
    /// this method does not follow links.
    public var isDirectoryFile: Bool {
        return fileType == .Directory
    }

    /// Returns `true` if the path is a symbolic link.
    ///
    /// this method does not follow links.
    public var isSymbolicLink: Bool {
        return fileType == .SymbolicLink
    }

    /// Returns `true` if the path is a regular file.
    ///
    /// this method does not follow links.
    public var isRegular: Bool {
        return fileType == .Regular
    }

    /// Returns `true` if the path exists any fileType item.
    ///
    /// this method does not follow links.
    public var isAny: Bool {
        return fileType != nil
    }

    /// The path's extension.
    public var pathExtension: String {
        get {
            return (rawValue as NSString).pathExtension
        }
        set {
            let path = (rawValue as NSString).stringByDeletingPathExtension
            rawValue = path + ".\(newValue)"
        }
    }

    /// The path's parent path.
    public var parent: Path {
        if isAbsolute {
            return Path((absolute.rawValue as NSString).stringByDeletingLastPathComponent)
        } else {
            let comps = components
            if comps.isEmpty {
                return Path("..")
            } else if comps.last!.rawValue == ".." {
                return ".." + self[comps.count - 1]
            } else if comps.count == 1 {
                return Path("")
            } else {
                return self[comps.count - 2]
            }
        }
    }

    // MARK: - Initialization

    /// Initializes a path to root.
    public init() {
        self = .Root
    }

    /// Initializes a path to the string's value.
    public init(_ path: String, expandingTilde: Bool = false) {
        // empty path may cause crash
        if expandingTilde {
            self.rawValue = (path as NSString).stringByExpandingTildeInPath
        } else {
            self.rawValue = path
        }
    }

}

extension Path {

    // MARK: - Methods

    /// Runs `closure` with `self` as its current working directory.
    ///
    /// - Parameter closure: The block to run while `Path.Current` is changed.
    ///
    public func changeDirectory(@noescape closure: () throws -> ()) rethrows {
        let previous = Path.Current
        defer { Path.Current = previous }
        if _fmWraper.fileManager.changeCurrentDirectoryPath(_safeRawValue) {
            try closure()
        }
    }

    /// Returns the path's children paths.
    ///
    /// - Parameter recursive: Whether to obtain the paths recursively.
    ///                        Default value is `false`.
    ///
    /// this method follow links if recursive is `false`, otherwise not follow links
    public func children(recursive recursive: Bool = false) -> [Path] {
        let obtainFunc = recursive
            ? _fmWraper.fileManager.subpathsOfDirectoryAtPath
            : _fmWraper.fileManager.contentsOfDirectoryAtPath
        return (try? obtainFunc(_safeRawValue))?.map { self + Path($0) } ?? []
    }

    /// Returns true if `path` is a child of `self`.
    ///
    /// - Parameter recursive: Whether to check the paths recursively.
    ///                        Default value is `true`.
    ///
    public func isChildOfPath(path: Path, recursive: Bool = true) -> Bool {
        if !(isRelative && path.isRelative) && !(isAbsolute && path.isAbsolute) {
            return self.absolute.isChildOfPath(path.absolute)
        }
        if isRoot {
            return true
        }
        if recursive {
            return path.isAncestorOfPath(self)
        } else {
            return path.parent == self
        }
    }

    /// Returns true if `path` is a parent of `self`.
    ///
    /// Relative paths can't be compared return `false`. like `../../path1/path2` and `../path2`
    ///
    public func isAncestorOfPath(path: Path) -> Bool {
        if !(isRelative && path.isRelative) && !(isAbsolute && path.isAbsolute) {
            return self.absolute.isAncestorOfPath(path.absolute)
        }
        if path.isRoot {
            return true
        }
        if self != path && self.commonAncestor(path) == path {
            return true
        }
        return false
    }

    /// Returns the common ancestor between `self` and `path`.
    ///
    /// Relative path return the most precise path if possible
    ///
    public func commonAncestor(path: Path) -> Path {
        if !(isRelative && path.isRelative) && !(isAbsolute && path.isAbsolute) {
            return self.absolute.commonAncestor(path.absolute)
        }
        let selfComponents = self.components
        let pathComponents = path.components

        let minCount = Swift.min(selfComponents.count, pathComponents.count)
        var total = minCount

        for index in 0 ..< total {
            if selfComponents[index].rawValue != pathComponents[index].rawValue {
                total = index
                break
            }
        }

        let ancestorComponents = selfComponents[0..<total]
        let common =  ancestorComponents.reduce("") { $0 + $1 }
        switch (self.relativePathType, path.relativePathType) {
        case (.Absolute, .Absolute), (.Normal, .Normal), (.Normal, .Current), (.Current, .Normal), (.Current, .Current):
            return common
        case (.Normal, .Parent), (.Current, .Parent), (.Parent, .Normal), (.Parent, .Current), (.Parent, .Parent):
            return Path("..")
        default:
            // count for prefix ".." in components
            var n1 = 0, n2 = 0
            for elem in selfComponents {
                if elem.rawValue == ".." {
                    n1 += 1
                } else {
                    break
                }
            }
            for elem in pathComponents {
                if elem.rawValue == ".." {
                    n2 += 1
                } else {
                    break
                }
            }
            if n1 == n2 {
                // paths like "../../common/path1" and "../../common/path2"
                return common
            } else {    // paths like "../path" and "../../path2/path1"
                let maxCount = Swift.max(n1, n2)
                var dotPath: Path = ""
                for _ in 0..<maxCount {
                    dotPath += ".."
                }
                return dotPath
            }
        }
    }

    /// Returns the relative path type.
    ///
    public var relativePathType: RelativePathType {
        if isAbsolute {
            return .Absolute
        } else {
            let comp = self.components
            switch comp.first?.rawValue {
            case nil:
                return .Current
            case ".."? where comp.count > 1:
                return .Ancestor
            case ".."?:
                return .Parent
            default:
                return .Normal
            }
        }
    }

    // swiftlint:disable line_length

    /// Returns paths in `self` that match a condition.
    ///
    /// - Parameter searchDepth: How deep to search before exiting. A negative
    ///                          value will cause the search to exit only when
    ///                          every subdirectory has been searched through.
    ///                          Default value is `-1`.
    /// - Parameter condition: If `true`, the path is added.
    ///
    /// - Returns: An Array containing the paths in `self` that match the
    ///            condition.
    ///
    public func find(searchDepth depth: Int = -1, @noescape condition: (Path) throws -> Bool) rethrows -> [Path] {
        return try self.find(searchDepth: depth) { path in
            try condition(path) ? path : nil
        }
    }

    /// Returns non-nil values for paths found in `self`.
    ///
    /// - Parameter searchDepth: How deep to search before exiting. A negative
    ///                          value will cause the search to exit only when
    ///                          every subdirectory has been searched through.
    ///                          Default value is `-1`.
    /// - Parameter transform: The transform run on each path found.
    ///
    /// - Returns: An Array containing the non-nil values for paths found in
    ///            `self`.
    ///
    public func find<T>(searchDepth depth: Int = -1, @noescape transform: (Path) throws -> T?) rethrows -> [T] {
        return try self.children().reduce([]) { values, child in
            if let value = try transform(child) {
                return values + [value]
            } else if depth != 0 {
                return try values + child.find(searchDepth: depth - 1, transform: transform)
            } else {
                return values
            }
        }
    }

    // swiftlint:enable line_length

    /// Standardizes the path.
    public mutating func standardize() {
        self = self.standardized
    }

    /// Resolves the path's symlinks and standardizes it.
    public mutating func resolve() {
        self = self.resolved
    }

    /// Creates a symbolic link at a path that points to `self`.
    ///
    /// - Parameter path: The Path to which at which the link of the file at
    ///                   `self` will be created.
    ///                   If `path` exists and is a directory, then the link
    ///                   will be made inside of `path`. Otherwise, an error
    ///                   will be thrown.
    ///
    /// - Throws:
    ///     `FileKitError.FileDoesNotExist`,
    ///     `FileKitError.CreateSymlinkFail`
    ///
    public func symlinkFileToPath(path: Path) throws {
        // it's possible to create symbolic links to locations that do not yet exist.
//        guard self.exists else {
//            throw FileKitError.FileDoesNotExist(path: self)
//        }

        let linkPath = path.isDirectory ? path + self.fileName : path

        // Throws if linking to an existing non-directory file.
        guard !linkPath.isAny else {
            throw FileKitError.CreateSymlinkFail(from: self, to: path)
        }

        do {
            try _fmWraper.fileManager.createSymbolicLinkAtPath(
                linkPath._safeRawValue, withDestinationPath: self._safeRawValue)
        } catch {
            throw FileKitError.CreateSymlinkFail(from: self, to: linkPath)
        }
    }

    /// Creates a hard link at a path that points to `self`.
    ///
    /// - Parameter path: The Path to which the link of the file at
    ///                   `self` will be created.
    ///                   If `path` exists and is a directory, then the link
    ///                   will be made inside of `path`. Otherwise, an error
    ///                   will be thrown.
    ///
    /// - Throws:
    ///     `FileKitError.FileDoesNotExist`,
    ///     `FileKitError.CreateHardlinkFail`
    ///
    public func hardlinkFileToPath(path: Path) throws {
        let linkPath = path.isDirectory ? path + self.fileName : path

        guard !linkPath.isAny else {
            throw FileKitError.CreateHardlinkFail(from: self, to: path)
        }

        do {
            try _fmWraper.fileManager.linkItemAtPath(self._safeRawValue, toPath: linkPath._safeRawValue)
        } catch {
            throw FileKitError.CreateHardlinkFail(from: self, to: path)
        }
    }

    /// Creates a file at path.
    ///
    /// Throws an error if the file cannot be created.
    ///
    /// - Throws: `FileKitError.CreateFileFail`
    ///
    /// this method does not follow links.
    ///
    /// If a file or symlink exists, this method removes the file or symlink and create regular file
    public func createFile() throws {
        if !_fmWraper.fileManager.createFileAtPath(_safeRawValue, contents: nil, attributes: nil) {
            throw FileKitError.CreateFileFail(path: self)
        }
    }

    /// Creates a file at path if not exist
    /// or update the modification date.
    ///
    /// Throws an error if the file cannot be created
    /// or if modification date could not be modified.
    ///
    /// - Throws:
    ///     `FileKitError.CreateFileFail`,
    ///     `FileKitError.AttributesChangeFail`
    ///
    public func touch(updateModificationDate: Bool = true) throws {
        if self.exists {
            if updateModificationDate {
                try _setAttribute(NSFileModificationDate, value: NSDate())
            }
        } else {
            try createFile()
        }
    }

    // swiftlint:disable line_length

    /// Creates a directory at the path.
    ///
    /// Throws an error if the directory cannot be created.
    ///
    /// - Parameter createIntermediates: If `true`, any non-existent parent
    ///                                  directories are created along with that
    ///                                  of `self`. Default value is `true`.
    ///
    /// - Throws: `FileKitError.CreateDirectoryFail`
    ///
    /// this method does not follow links.
    ///
    public func createDirectory(withIntermediateDirectories createIntermediates: Bool = true) throws {
        do {
            let manager = _fmWraper.fileManager
            try manager.createDirectoryAtPath(_safeRawValue,
                withIntermediateDirectories: createIntermediates,
                attributes: nil)
        } catch {
            throw FileKitError.CreateDirectoryFail(path: self)
        }
    }

    // swiftlint:enable line_length

    /// Deletes the file or directory at the path.
    ///
    /// Throws an error if the file or directory cannot be deleted.
    ///
    /// - Throws: `FileKitError.DeleteFileFail`
    ///
    /// this method does not follow links.
    public func deleteFile() throws {
        do {
            try _fmWraper.fileManager.removeItemAtPath(_safeRawValue)
        } catch {
            throw FileKitError.DeleteFileFail(path: self)
        }
    }

    /// Moves the file at `self` to a path.
    ///
    /// Throws an error if the file cannot be moved.
    ///
    /// - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.MoveFileFail`
    ///
    /// this method does not follow links.
    public func moveFileToPath(path: Path) throws {
        if self.isAny {
            if !path.isAny {
                do {
                    try _fmWraper.fileManager.moveItemAtPath(self._safeRawValue, toPath: path._safeRawValue)
                } catch {
                    throw FileKitError.MoveFileFail(from: self, to: path)
                }
            } else {
                throw FileKitError.MoveFileFail(from: self, to: path)
            }
        } else {
            throw FileKitError.FileDoesNotExist(path: self)
        }
    }

    /// Copies the file at `self` to a path.
    ///
    /// Throws an error if the file at `self` could not be copied or if a file
    /// already exists at the destination path.
    ///
    /// - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.CopyFileFail`
    ///
    /// this method does not follow links.
    public func copyFileToPath(path: Path) throws {
        if self.isAny {
            if !path.isAny {
                do {
                    try _fmWraper.fileManager.copyItemAtPath(self._safeRawValue, toPath: path._safeRawValue)
                } catch {
                    throw FileKitError.CopyFileFail(from: self, to: path)
                }
            } else {
                throw FileKitError.CopyFileFail(from: self, to: path)
            }
        } else {
            throw FileKitError.FileDoesNotExist(path: self)
        }
    }

}

extension Path {

    // MARK: - StringLiteralConvertible

    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

    public typealias UnicodeScalarLiteralType = StringLiteralType

    /// Initializes a path to the literal.
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.rawValue = value
    }

    /// Initializes a path to the literal.
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }

    /// Initializes a path to the literal.
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.rawValue = value
    }

}

extension Path {

    // MARK: - RawRepresentable

    /// Initializes a path to the string value.
    ///
    /// - Parameter rawValue: The raw value to initialize from.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

}

extension Path {

    // MARK: - Hashable

    /// The hash value of the path.
    public var hashValue: Int {
        return rawValue.hashValue
    }

}

extension Path {

    // MARK: - Indexable

    /// The path's start index.
    public var startIndex: Int {
        return components.startIndex
    }

    /// The path's end index; the successor of the last valid subscript argument.
    public var endIndex: Int {
        return components.endIndex
    }

    /// The path's subscript. (read-only)
    ///
    /// - Returns: All of the path's elements up to and including the index.
    ///
    public subscript(index: Int) -> Path {
        let components = self.components
        if index < 0 || index >= components.count {
            fatalError("Path index out of range")
        } else {
            var result = components.first!
            for i in 1 ..< index + 1 {
                result += components[i]
            }
            return result
        }
    }

}

extension Path {

    // MARK: - Attributes

    /// Returns the path's attributes.
    ///
    /// this method does not follow links.
    public var attributes: [String : AnyObject] {
        return (try? _fmWraper.fileManager.attributesOfItemAtPath(_safeRawValue)) ?? [:]
    }

    /// Modify attributes
    ///
    /// this method does not follow links.
    private func _setAttributes(attributes: [String : AnyObject]) throws {
        do {
            try _fmWraper.fileManager.setAttributes(attributes, ofItemAtPath: self._safeRawValue)
        } catch {
            throw FileKitError.AttributesChangeFail(path: self)
        }
    }

    /// Modify one attribute
    private func _setAttribute(key: String, value: AnyObject) throws {
        try _setAttributes([key : value])
    }

    /// The creation date of the file at the path.
    public var creationDate: NSDate? {
        return attributes[NSFileCreationDate] as? NSDate
    }

    /// The modification date of the file at the path.
    public var modificationDate: NSDate? {
        return attributes[NSFileModificationDate] as? NSDate
    }

    /// The name of the owner of the file at the path.
    public var ownerName: String? {
        return attributes[NSFileOwnerAccountName] as? String
    }

    /// The ID of the owner of the file at the path.
    public var ownerID: UInt? {
        if let value = attributes[NSFileOwnerAccountID] as? NSNumber {
            return value.unsignedLongValue
        }
        return nil
    }

    /// The group name of the owner of the file at the path.
    public var groupName: String? {
        return attributes[NSFileGroupOwnerAccountName] as? String
    }

    /// The group ID of the owner of the file at the path.
    public var groupID: UInt? {
        if let value = attributes[NSFileGroupOwnerAccountID] as? NSNumber {
            return value.unsignedLongValue
        }
        return nil
    }

    /// Indicates whether the extension of the file at the path is hidden.
    public var extensionIsHidden: Bool? {
        if let value = attributes[NSFileExtensionHidden] as? NSNumber {
            return value.boolValue
        }
        return nil
    }

    /// The POSIX permissions of the file at the path.
    public var posixPermissions: Int16? {
        if let value = attributes[NSFilePosixPermissions] as? NSNumber {
            return value.shortValue
        }
        return nil
    }

    /// The number of hard links to a file.
    public var fileReferenceCount: UInt? {
        if let value = attributes[NSFileReferenceCount] as? NSNumber {
            return value.unsignedLongValue
        }
        return nil
    }

    /// The size of the file at the path in bytes.
    public var fileSize: UInt64? {
        if let value = attributes[NSFileSize] as? NSNumber {
            return value.unsignedLongLongValue
        }
        return nil
    }

    /// The filesystem number of the file at the path.
    public var filesystemFileNumber: UInt? {
        if let value = attributes[NSFileSystemFileNumber] as? NSNumber {
            return value.unsignedLongValue
        }
        return nil
    }
}

extension Path {

    // MARK: - FileType

    /// The FileType attribute for the file at the path.
    public var fileType: FileType? {
        guard let value = attributes[NSFileType] as? String else {
            return nil
        }
        return FileType(rawValue: value)
    }

}

extension Path {

    // MARK: - FilePermissions

    /// The permissions for the file at the path.
    public var filePermissions: FilePermissions {
        return FilePermissions(forPath: self)
    }

}

extension Path {

    // MARK: - NSURL

    /// Creates a new path with given url if possible.
    ///
    /// - Parameter url: The url to create a path for.
    public init?(url: NSURL) {
        guard let path = url.path where url.fileURL else {
            return nil
        }
        rawValue = path
    }

    /// - Returns: The `Path` objects url.
    public var url: NSURL {
        return NSURL(fileURLWithPath: _safeRawValue, isDirectory: self.isDirectory)
    }

}

extension Path {

    // MARK: - BookmarkData

    /// Creates a new path with given url if possible.
    ///
    /// - Parameter bookmarkData: The bookmark data to create a path for.
    public init?(bookmarkData bookData: NSData) {
        var isStale: ObjCBool = false
        let url = try? NSURL(
            byResolvingBookmarkData: bookData,
            options: [],
            relativeToURL: nil,
            bookmarkDataIsStale: &isStale)
        guard let fullURL = url else {
            return nil
        }
        self.init(url: fullURL)
    }

    /// - Returns: The `Path` objects bookmarkData.
    public var bookmarkData: NSData? {
        return try? url.bookmarkDataWithOptions(
            .SuitableForBookmarkFile,
            includingResourceValuesForKeys: nil,
            relativeToURL: nil)
    }

}

extension Path {

    // MARK: - SecurityApplicationGroupIdentifier

    /// Returns the container directory associated with the specified security application group ID.
    ///
    /// - Parameter groupIdentifier: The group identifier.
    public init?(groupIdentifier: String) {
        guard let url = NSFileManager().containerURLForSecurityApplicationGroupIdentifier(groupIdentifier) else {
            return nil
        }
        self.init(url: url)
    }

}

extension Path {

    // MARK: - NSFileHandle

    /// Returns a file handle for reading the file at the path, or `nil` if no
    /// file exists.
    public var fileHandleForReading: NSFileHandle? {
        return NSFileHandle(forReadingAtPath: absolute._safeRawValue)
    }

    /// Returns a file handle for writing to the file at the path, or `nil` if
    /// no file exists.
    public var fileHandleForWriting: NSFileHandle? {
        return NSFileHandle(forWritingAtPath: absolute._safeRawValue)
    }

    /// Returns a file handle for reading and writing to the file at the path,
    /// or `nil` if no file exists.
    public var fileHandleForUpdating: NSFileHandle? {
        return NSFileHandle(forUpdatingAtPath: absolute._safeRawValue)
    }

}

extension Path {

    // MARK: - NSStream

    /// Returns an input stream that reads data from the file at the path, or
    /// `nil` if no file exists.
    public func inputStream() -> NSInputStream? {
        return NSInputStream(fileAtPath: absolute._safeRawValue)
    }

    /// Returns an output stream for writing to the file at the path, or `nil`
    /// if no file exists.
    ///
    /// - Parameter shouldAppend: `true` if newly written data should be
    ///                           appended to any existing file contents,
    ///                           `false` otherwise. Default value is `false`.
    ///
    public func outputStream(append shouldAppend: Bool = false) -> NSOutputStream? {
        return NSOutputStream(toFileAtPath: absolute._safeRawValue, append: shouldAppend)
    }

}

extension Path: StringInterpolationConvertible {

    // MARK: - StringInterpolationConvertible

    /// Initializes a path from the string interpolation paths.
    public init(stringInterpolation paths: Path...) {
        self.init(paths.reduce("", combine: { $0 + $1.rawValue }))
    }

    /// Initializes a path from the string interpolation segment.
    public init<T>(stringInterpolationSegment expr: T) {
        if let path = expr as? Path {
            self = path
        } else {
            self = Path(String(expr))
        }
    }

}

extension Path: CustomStringConvertible {

    // MARK: - CustomStringConvertible

    /// A textual representation of `self`.
    public var description: String {
        return rawValue
    }

}


extension Path: CustomDebugStringConvertible {

    // MARK: - CustomDebugStringConvertible

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        return "Path(\(rawValue.debugDescription))"
    }

}

extension Path: SequenceType {

    // MARK: - SequenceType

    /// - Returns: A *generator* over the contents of the path.
    public func generate() -> DirectoryEnumerator {
        return DirectoryEnumerator(path: self)
    }

}


extension Path {

    // MARK: - Paths

    /// Returns the path to the user's or application's home directory,
    /// depending on the platform.
    public static var UserHome: Path {
        return Path(NSHomeDirectory()).standardized
    }

    /// Returns the path to the user's temporary directory.
    public static var UserTemporary: Path {
        return Path(NSTemporaryDirectory()).standardized
    }

    /// Returns a temporary path for the process.
    public static var ProcessTemporary: Path {
        return Path.UserTemporary + NSProcessInfo.processInfo().globallyUniqueString
    }

    /// Returns a unique temporary path.
    public static var UniqueTemporary: Path {
        return Path.ProcessTemporary + NSUUID().UUIDString
    }

    /// Returns the path to the user's caches directory.
    public static var UserCaches: Path {
        return _pathInUserDomain(.CachesDirectory)
    }

    /// Returns the path to the user's applications directory.
    public static var UserApplications: Path {
        return _pathInUserDomain(.ApplicationDirectory)
    }

    /// Returns the path to the user's application support directory.
    public static var UserApplicationSupport: Path {
        return _pathInUserDomain(.ApplicationSupportDirectory)
    }

    /// Returns the path to the user's desktop directory.
    public static var UserDesktop: Path {
        return _pathInUserDomain(.DesktopDirectory)
    }

    /// Returns the path to the user's documents directory.
    public static var UserDocuments: Path {
        return _pathInUserDomain(.DocumentDirectory)
    }

    /// Returns the path to the user's autosaved documents directory.
    public static var UserAutosavedInformation: Path {
        return _pathInUserDomain(.AutosavedInformationDirectory)
    }

    /// Returns the path to the user's downloads directory.
    public static var UserDownloads: Path {
        return _pathInUserDomain(.DownloadsDirectory)
    }

    /// Returns the path to the user's library directory.
    public static var UserLibrary: Path {
        return _pathInUserDomain(.LibraryDirectory)
    }

    /// Returns the path to the user's movies directory.
    public static var UserMovies: Path {
        return _pathInUserDomain(.MoviesDirectory)
    }

    /// Returns the path to the user's music directory.
    public static var UserMusic: Path {
        return _pathInUserDomain(.MusicDirectory)
    }

    /// Returns the path to the user's pictures directory.
    public static var UserPictures: Path {
        return _pathInUserDomain(.PicturesDirectory)
    }

    /// Returns the path to the user's Public sharing directory.
    public static var UserSharedPublic: Path {
        return _pathInUserDomain(.SharedPublicDirectory)
    }

    #if os(OSX)

    /// Returns the path to the user scripts folder for the calling application
    public static var UserApplicationScripts: Path {
        return _pathInUserDomain(.ApplicationScriptsDirectory)
    }

    /// Returns the path to the user's trash directory
    public static var UserTrash: Path {
        return _pathInUserDomain(.TrashDirectory)
    }

    #endif

    /// Returns the path to the system's applications directory.
    public static var SystemApplications: Path {
        return _pathInSystemDomain(.ApplicationDirectory)
    }

    /// Returns the path to the system's application support directory.
    public static var SystemApplicationSupport: Path {
        return _pathInSystemDomain(.ApplicationSupportDirectory)
    }

    /// Returns the path to the system's library directory.
    public static var SystemLibrary: Path {
        return _pathInSystemDomain(.LibraryDirectory)
    }

    /// Returns the path to the system's core services directory.
    public static var SystemCoreServices: Path {
        return _pathInSystemDomain(.CoreServiceDirectory)
    }

    /// Returns the path to the system's PPDs directory.
    public static var SystemPrinterDescription: Path {
        return _pathInSystemDomain(.PrinterDescriptionDirectory)
    }

    /// Returns the path to the system's PreferencePanes directory.
    public static var SystemPreferencePanes: Path {
        return _pathInSystemDomain(.PreferencePanesDirectory)
    }

    /// Returns the paths where resources can occur.
    public static var AllLibraries: [Path] {
        return _pathsInDomains(.AllLibrariesDirectory, .AllDomainsMask)
    }

    /// Returns the paths where applications can occur
    public static var AllApplications: [Path] {
        return _pathsInDomains(.AllApplicationsDirectory, .AllDomainsMask)
    }

    private static func _pathInUserDomain(directory: NSSearchPathDirectory) -> Path {
        return _pathsInDomains(directory, .UserDomainMask)[0]
    }

    private static func _pathInSystemDomain(directory: NSSearchPathDirectory) -> Path {
        return _pathsInDomains(directory, .SystemDomainMask)[0]
    }

    private static func _pathsInDomains(directory: NSSearchPathDirectory,
        _ domainMask: NSSearchPathDomainMask) -> [Path] {
        return NSSearchPathForDirectoriesInDomains(directory, domainMask, true)
            .map({ Path($0).standardized })
    }

}
