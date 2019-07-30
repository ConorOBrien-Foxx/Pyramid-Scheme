# Pyramid Scheme

Pyramids!

## What is this language?

Pyramid Scheme is most similar in evaluation style to a LISP-like language. However, instead of anything _sane_ like parentheses to group evaluation order, Pyramid Scheme unsurprisingly uses Pyramids. Yes, Pyramids. The "root" of evaluation is collected on the first line; any `^` character on the first line indicates the beginning of a pyramid. Then, a pyramid must have `/` and `\` characters stemming downards from the `^`, finally closed off by a line of `-`s. Here is an example of a blank Pyramid:

```
  ^
 / \
/   \
-----
```

As far as writing programs goes, what's important to us here is not the height or width of the Pyramid, but rather how many character can fit inside a Pyramid. The above Pyramid can hold 4 characters inside of it; 1 for the first row, and 3 for the second. In general, a Pyramid of order **N** can contain simply **N<sup>2</sup>** characters.

A Pyramid can either be _leaf_ or a _node_. Leaves represent data, and look much like the above Pyramids. Leaves become nodes when they are supplied arguments. An argument is supplied to a Pyramid by construct another Pyramid whose tip is adjacent to the bottom of another Pyramid. Here are two Pyramids, one leaf and one node, labeled `A` and `B` respectively.

```
  ^
 / \
/ A \
-----^
    /B\
    ---
```

In a LISP-like language, this would be equivalent to `(A B)`. In a normal language, this is `A(B)`. Pyramids can have up to two arguments:

```
    ^
   / \
  / A \
 ^-----^
/B\   / \
---  / C \
     -----
```

Equivalent to `(A B C)` or `A(B, C)`.

_Note: Pyramids are evaluated depth-first; it is possible for certain Pyramids to be evaluated twice this way. See the third example for more info._

That's the Crux of the language! Next, we'll learn about the commands available to the language.

## Commands

There is a limited set of functions, catalogued in this table below. Arity refers to the number of arguments the function requires. For notational purposes, `a` refers to the left argument and `b` refers to the right argument. If a function is "evaluated", it does not do anything special to its arguments. Unevaluated functions are usually used for control flow, or evaluating an expression multiple times.

| Name       | Arity | Evaluated? | Function |
| ---------- | ----- | ---------- | -------- |
| `+`        | 2     | Yes        | `a + b`  |
| `-`        | 2     | Yes        | `a - b`  |
| `*`        | 2     | Yes        | `a * b`  |
| `/`        | 2     | Yes        | `a / b`  |
| `^`        | 2     | Yes        | `pow(a, b)` |
| `=`        | 2     | Yes        | `1` if `a == b`; `0` otherwise |
| `<=>`      | 2     | Yes        | `1` if `a > b`; `0` if `a == b`; `-1` if `a < b`. |
| `out`      | 1..2  | Yes        | Prints `a` (followed by `b` if provided) without trailing newline |
| `chr`      | 1     | Yes        | Converts `a` to an integer, then to a UTF-8 character. |
| `arg`      | 1..2  | Yes        | Obtains the `b`th element of `a`; if no `b` is provided, obtain the `a`th command line argument. |
| `#`        | 1     | Yes        | Converts a string to a value; if it exists as a variable name, get that variable. If the string is one of `line`, `stdin`, or `readline`, read a line from STDIN; otherwise, convert it to a float. |
| `"`        | 1     | Yes        | Convert the argument to a string. |
| (blank)    | 1     | Yes        | Identity function; return `a`. |
| `!`        | 1     | Yes        | Logical negation; `0` if `a` is `truthy`, `1` otherwise. |
| `[`        | 1     | Yes        | `a` |
| `]`        | 1     | Yes        | `b` |
| `set`      | 2     | No         | sets variable denoted by `a` to the evaluated value `b` |
| `do`       | 2     | No         | Evaluates `b` (at least once) while `a` evaluates to true. |
| `loop`     | 2     | No         | While `a` evaluates to true, evaluate `b` (0 or more times). |
| `?`        | 2     | No         | If `a` is truthy, evaluate and return `b`; otherwise, return `0`. |


## Example programs

Truth machine, a program that outputs infinite `1`s when supplied a `1`, or a single `0` when supplied a `0`.

        ^        ^
       / \      / \
      /set\    /do \
     ^-----^  ^-----^
    /a\   /#\/a\   / \
    ---  ^------  /out\
        / \      ^-----
       /   \    /a\
      /line \   ---
      -------

This is equivalent to the LISP-like:

```
(set a (# line)) (do a (out a))
```

Or in a Python-like language:

```
a = input()
while a:
    print(a)
```

----

Here's an if-else statement for the variable `A` (prints `1` for truthy, `0` for falsey):

           ^
          /?\
         ^---^
        /!\ / \
       ^---/out\
      /?\  -----^
     ^---^     /0\
    /A\ / \    ---
    ---/out\
      ^-----
     /1\
     ---

Here is an example of a Pyramid being evaluated twice, as it is the child of two different nodes.

```
     ^
    /+\
   ^---^
  /+\ /*\
 ^---^---^
/1\ /3\ /4\
--- --- ---
```

This is equivalent to (1 + **3**) + (**3** * 4) = 4 + 12 = 16.
