extension Sequence where Element: Numeric {
    @inlinable
    public func sum() -> Element {
        self.reduce(0, +)
    }
}
