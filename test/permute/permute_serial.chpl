use functional;

var numbers = permute([1,2,3,4]);
var characters = permute(["a", "b", "c", "d"]);

var counter = 1;                                // it is easier to know the correctness from how many permutations produced

for permutation in numbers {
    writeln(counter, " -> ", permutation);
    counter = counter + 1;
}

writeln(); counter = 1;

for permutation in characters {
    writeln(counter, " -> ", permutation);
    counter = counter + 1;
}