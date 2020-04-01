module utilities {
    proc isEqual(a, b) : bool {
        for (i, j) in zip(a, b) {
            if i != j {
                return false;
            }
        }
        return true;
    }
}