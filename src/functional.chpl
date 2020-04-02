

/*

  This module provides utilities supporting the elegant
  and verbose style of the functional paradigm, with utilities
  for efficient iteration, and lazy computations and evalutation.

  
  
*/


private use RangeChunk;


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
                var nowRange = chunk(start..end, numTasks, tid);
                for i in nowRange {
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
                var nowRange = chunk(start..end, numTasks, tid).translate(-start); 
                yield (nowRange,);
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