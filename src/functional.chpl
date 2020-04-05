

/*

  This module provides utilities supporting the elegant
  and verbose style of the functional paradigm, with utilities
  for efficient iteration, and lazy computations and evalutation.

  
  
*/


private use RangeChunk;
private use Set;
private use List;


// I copied some stuff from the master branch so I could get to know errors and
// get a sense about how code should be in Chapel.



/*
    Return an iterator that returns an evenly spaced integer values starting
    with `start` to `end` with `step` space between each element. OR you can use ranges instead :).

    :arg start: the first element
    :type start: `int`

    :arg step: the space between consecutive elements
    :type step: `int`

    :arg end: the last element
    :type end: `int`
*/


// serial iterator
iter count(in start: int, in step: int, in end: int = 0) { 
  if end == 0 then                  
    for i in start.. by step do
        yield i;
  else  
    for i in start..end by step do
        yield i;
}


// standalone iterator
pragma "no doc"
iter count(param tag:iterKind, in start: int, in step: int, in end: int = 0)
    where tag == iterKind.standalone {
    try! {
        var numTasks = here.maxTaskPar;
        if end == 0 then
            throw new owned IllegalArgumentError(
                "Infinite iteration not supported for parallel loops");
        else
            coforall tid in 0..#numTasks {
                var tidRange = chunk(start..end, numTasks, tid);
                for i in tidRange {
                    if (i - start) % step == 0 {        // we need to do this because
                        yield i;                        // we need a reference point
                    }                                   // for every chunk
                }
            }
    }
}


// leader iterator
pragma "no doc"
iter count(param tag: iterKind, in start: int, in step: int, in end: int = 0) 
    where tag == iterKind.leader {
    try! {
        var numTasks = here.maxTaskPar;
        if end == 0 then
            throw new owned IllegalArgumentError(
                "Infinite iteration not supported for parallel loops");
        else
            coforall tid in 0..#numTasks {
                var tidRange = chunk(start..end, numTasks, tid).translate(-start); 
                yield (tidRange,);
            }
    }
}


// follower iterator
pragma "no doc"
iter count(param tag: iterKind, in start: int, in step: int, in end: int = 0, followThis)
    where tag == iterKind.follower && followThis.size == 1 {
    var nowIter = followThis(1).translate(start);
    for i in nowIter {
        if (i - start) % step == 0 {        // we need to do this because
            yield i;                        // we need a reference point
        }                                   // for every chunk
    }
}



////////////////////////////////////////////////////////////////////////////////////////




/*

    Make an iterator that returns consecutive functions and groups from the iterable. 
    The function is a function computing a value for each element.

    :arg iterable: this is a container of generic objects you wish to group based on a common trait
    :type iterable: `? []`

    :arg function: this is the grouping function which returns a specific trait


*/


// serial
iter groupby(iterable, function) {

    // getting the types of our data structures
    type traitType = function(iterable[1]).type;
    type objectType = iterable[1].type;

    var Traits : set(traitType);    

    for i in iterable {  
        var Trait = function(i);                    
        if Traits.contains(Trait) then continue;                // set won't admit duplicates but we need to continue
        Traits.add(Trait);                                      // to skip the innermost loop. Otherwise we would have 
                                                                            // duplicate groups.
        var tobeYielded: list(objectType) = new list(objectType);
        for object in iterable {
            if function(object) == Trait {
                tobeYielded.insert(1,object);
            }
        }
        yield tobeYielded.toArray();
    }
}




// standalone
pragma "no doc"
iter groupby(param tag:iterKind, iterable, function)
    where tag == iterKind.standalone {
    var numTasks = here.maxTaskPar;
    type traitType = function(iterable[1]).type;
    type objectType = iterable[1].type;

    var Traits : set(traitType);

    for object in iterable {
        Traits.add(function(object));
    }
    
    // we need to have an indexed data structure so that every follower could 
    // be responsible for a portion of the common trait list and yield depending on
    // the traits provided for it in this sub-"set"
    
    var TraitArr = Traits.toArray();
    var _range = TraitArr.domain.low..TraitArr.domain.high;

    coforall tid in 0..#numTasks {
        var tidRange = chunk(_range, numTasks, tid);
        for i in tidRange {
            var TraitObjects: list(objectType) = new list(objectType);
            for object in iterable {
                if function(object) == TraitArr[i] {
                    TraitObjects.insert(1, object);
                }
            }
            yield TraitObjects.toArray();
        }
    }
}




// leader
pragma "no doc"
iter groupby(param tag:iterKind, iterable, function)
    where tag == iterKind.leader {
        var numTasks = here.maxTaskPar;
        type traitType = function(iterable[1]).type;
        type objectType = iterable[1].type;
        
        var Traits : set(traitType);
        for i in iterable {
            Traits.add(function(i));         // we would have only one copy of each trait
        }
        var TraitArr = Traits.toArray();     // this array need to be passed to every follower :(

        var _range = TraitArr.domain.low..TraitArr.domain.high;
        coforall tid in 0..#numTasks {
            var tidRange = chunk(_range, numTasks, tid);
            yield (tidRange, TraitArr, );
        }
}



// follower
pragma "no doc"
iter groupby(param tag:iterKind, iterable, function, followThis)
    where tag == iterKind.follower && followThis.size == 2 {
        var tidRange = followThis(1);
        var Traits = followThis(2);
        type objectType = iterable[1].type;

        for i in tidRange {
            var tobeYielded: list(objectType) = new list(objectType);
            for object in iterable {
                if function(object) == Traits[i] {
                    tobeYielded.insert(1, object);
                }
            }
            yield tobeYielded.toArray();
        }
}


