<h1 align="center">Itertools for Chapel</h1>


`itertools` is a true gem for programmers with its origins in lisp and haskell and other functional programming languages and thanks to python for its elegant and succinct implementation for *most* of what haskellers brag about in its venerable functional programming modules namely itertools, functools, and operator.

There is no need to talk about what a library called `itertools` would do, but let's talk what `chapel` can add to it. [`Chapel`](https://en.wikipedia.org/wiki/Chapel_(programming_language)) is a parallel programming language that can easily be configured to run on multiple locales with off-the-shelf abstractions to deal with task/data parallelis. The language creators introduced the concept of parallel iterators in [User-Defined Parallel Zippered Iterators in Chapel](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.230.5560) in which you can have a signle generator that yields data produced from a iterators working on a different and separate locales, which obviously boast the preformance of a typical generator function working on a single container by distributing the work on multiple workers/iterators.


#


I'll be implementing two versions for each function: the serial version, and the parallel version, and I'll make sure to indicate if any of the two versions for the same function is missing. Okay, let's start.


#

All the iterator functions could be grouped into three categories introduced in the Python's `itertools` documention</br>
1. [Infinite Iterators](#Infinite-Iterators)
2. [Iterators terminating on the shortest input sequence](#Iterators-terminating-on-the-shortest-input-sequence)
3. [Combinatoric iterators](#Combinatoric-iterators)

# Infinite Iterators

|Function|Short Description|Parallel Version|
|---|---|---|

# Iterators terminating on the shortest input sequence

|Function|Short Description|Parallel Version|
|---|---|---|

# Combinatoric iterators

|Function|Short Description|Parallel Version|
|---|---|---|
