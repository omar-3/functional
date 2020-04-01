use UnitTest;
use functional;

//////////////////////////////////////////////////////////////////////////////
proc isEqual(a, b) : bool {         // return true if the two arrays are equal
    for (i, j) in zip(a, b) {
        if i != j {
            return false;
        }
    }
    return true;
}
////////////////////////////////////////////////////////////////////////////////


proc testCount(test: borrowed Test) throws {
    var input = count(1, 2, 12);
    var output = [1, 3, 5, 7, 9, 11];
    test.assertTrue(isEqual(input, output));
}

UnitTest.main();