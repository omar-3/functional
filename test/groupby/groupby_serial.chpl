use functional;


// partition an array of numbers into odd array and even array

var numbers = [1,2,3,4,5,1,3,5,3,6,8,9,10,12,14,6,3,1,7,2,9,10,1,5,4];

proc is_even(x: int) : bool {
        return x % 2 == 0;
}

var odd_and_even = groupby(numbers, is_even);

writeln(odd_and_even(1));       // odd
writeln(odd_and_even(2));       // even


writeln();


// partitiong an array of tuples based on the commonality of the first element in the tuple

var things = [("animal", "bear"), ("plant", "cactus"), ("vehicle", "speed boat"), ("animal", "duck"), ("vehicle", "school bus")];

proc first_element(x: 2*string) : string {
    return x(1);
}

var animals_plants_vehicles = groupby(things, first_element);

writeln(animals_plants_vehicles(1));        // animals
writeln(animals_plants_vehicles(2));        // plants
writeln(animals_plants_vehicles(3));        // vehicles