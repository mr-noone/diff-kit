import Foundation

public struct SectionSetIterator<Item: Equatable, Header: Equatable, Footer: Equatable>: IteratorProtocol {
    public typealias SectionSet = DiffKit.SectionSet<Item, Header, Footer>
    public typealias Element = SectionSet.Element
    
    // MARK: - Properties
    
    private let sectionSet: SectionSet
    private var index: SectionSet.Index
    
    // MARK: - Inits
    
    init(sectionSet: SectionSet) {
        self.sectionSet = sectionSet
        self.index = sectionSet.startIndex
    }
    
    // MARK: - Methods
    
    public mutating func next() -> Element? {
        guard index < sectionSet.endIndex else { return nil }
        guard sectionSet.countOfSections > index[0],
              sectionSet.countOfItems(in: index[0]) > index[1]
        else {
            index = sectionSet.index(after: index)
            return next()
        }
        
        let element = sectionSet[index]
        index = sectionSet.index(after: index)
        return element
    }
}
