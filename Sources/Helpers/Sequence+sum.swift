extension Sequence where Element: Numeric {
    public func sum() -> Element {
        self.reduce(0, +)
    }
}
