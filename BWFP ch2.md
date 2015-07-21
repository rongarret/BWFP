#Bit Wrangling for Fun and Profit (DRAFT)

## Chapter 2: Your first toolkit

Writing software is process of making complicated things out of simpler things.  At the bottom of this process is a set of *primitives* which are just given to you as if they were wishes granted by a genie in a bottle.  We've already seen some examples of this.  The ability to do arithmetic has been given to you as a primitive.  Arithmetic might seem simple, but in fact there is a lot of complexity behind the scenes, some of which you will already have glimpsed if you followed my suggestion in Chapter 1 and did a meta-point on SQRT.  (If you didn't do it then, I encourage you to do it now.)

Where the process of writing software "bottoms out" is in the primitives that are provided by the hardware.  If you really want to have a full understanding of what goes on under the hood you should read the "Code" book that I suggested in Chapter 1.  If we were taking a bottom-up approach the way that book does, we would start with those primitives and build up from there.  But that is tedious, and it would be a very long time before we got to the point where we could build a web site that way.

So I am going to give you a different starting point so we can go "middle out".  The set of primitives that I am going to give you are more complicated than what you get directly from the hardware (or, to use the parlance of the trade, what you get from the "bare metal") but still conceptually simple.  We will eventually learn how these "mid-level" primitives are built.  In fact, you will eventually build your own (the mark of a master is when he builds his own tools).  But for now we will use tools that have been built for us by others.

The primitives we will use fall into three or four major classes depending on how you count.  These are:

1.  Functions, which we can further subdivide into stateless "true" functions, and stateful functions.
2.  Binding and assignment constructs
3.  Control constructs

Note that this is not the top-level division that you will find in most textbooks.  There you will find things divided up into *functions*, *macros*, and *special forms*.  The reason I don't think this is a good way to view the world is that the difference between macros and special forms is how they are *implemented* rather than what they *do*.  I think the latter is a better way to view things.

## Functions

A function takes a set of inputs and produces an output (possibly more than one).  What distinguishes a function from other kinds of primitives is that their outputs depend *only* on their inputs.  The arithmetic operations we have already met are all functions.

There is a second kind of primitive that looks like a function but behaves somewhat differently.  Here's an example:

	? (random 1.0)
	0.7192276

RANDOM takes an input and produces an output, but the output is not always the same for a given input.  If you invoke (random 1.0) twice you will get (with very high probability) two different results.  We can still consider RANDOM to be a function, but one that has a *hidden input* that comes from some *persistent state* (and, in the case of RANDOM, that state changes every time it is invoked).  State turns out to be a huge complication, arguably the biggest complication in all of computer science.  For this reason we will distinguish "state-ful" functions like RANDOM from "pure" functions like arithmetic operations.

### Binding and assignment

The second class of primitives are *binding* and *assignment* operations.  "Binding" simply means taking a computed value and giving it a name so you can refer to it later.  We have already met one binding construct: DEFUN.  DEFUN actually is two *different* binding constructs rolled into one.  Consider:

	(defun square (x) (* x x))

This creates a function that takes one input, a number, and returns that number multiplied by itself.  That function is then given the name (i.e. bound to) SQUARE.  So DEFUN binds a function to a name.  But it also binds the *argument* to the function to the name X.

There is an important difference between the way SQUARE is bound and the way X is bound.  The binding of SQUARE is *persistent*, that is, it remain in place even after the DEFUN has finished executing (that's the whole point!)  But the binding of X is *transient*.  It exists only while SQUARE is being computed.

	? (defun square (x) (* x x))
	SQUARE
	? (square 3)
	9
	? x
	> Error: Unbound variable: X

We can also create a persistent binding of X using DEFV instead of DEFUN:

	? (defv x 123)
	X
	? x
	123
	? (square 3)
	9

Note that DEFV is part of Ergolib, not Common Lisp.  Note also that the binding of X inside SQUARE *shadows* the persistent binding we created with DEFV, that is, while SQUARE is running, its X is the X that was passed in as an argument.  We could also write:

	? (defun global-square () (* x x))
	GLOBAL-SQUARE
	? (global-square)
	15129

We can *change* the value of an existing binding using SETF:

	? (setf x 42)
	42
	? x
	42
	? (global-square)
	1764

This seems fairly inoccuous, and indeed it is common practice in other programming languages.  At this point you are going to just have to take my word for it when I tell you that you have just caught your first glimpse of the Eye of Sauron.  Assignment changes everything in very dramatic ways, but it will take a while before we get there.  For now, just take it on faith that SETF is generally something to avoid if you can.

So... if you can't use SETF, what do you use if you want to give a name to an intermediate result in a computation?  For that, you want BINDING-BLOCK, or BB for short.  BINDING-BLOCK works more or less like SETF, except that the variables you create only exist inside the binding block.  For example:

	? (binding-block x (+ 1 2) y (* 3 4) (* x y))
	36

Normally you would use the abbreviation BB rather than writing out BINDING-BLOCK, and you'd put each variable on its own line to make it a little more clear what is going on, i.e.:

	? (bb x (+ 1 2)
	      y (* 3 4)
	      (* x y))
	36

Notice how the indentation makes it easier to follow the structure of the code.  The Clozure IDE will automatically indent code for you if you press the TAB key.

NOTE: BB is part of Ergolib, not Common Lisp.  The Common Lisp equivalent of BB is called LET, and it works more or less the same way except LET uses more parentheses.  Also, BB has a few extra features that LET doesn't have, but those will have to wait until later.

### Control constructs

The third kind of primitive is the *control construct*.  The only one I'm going to introduce at this point is the *conditional*, but there are many others, a few dozen in total.

Even amongst conditionals there are many variants, and again I'm only going to give you two right now, both to keep things simple, and also because they're really all you will need for a long, long time.  The simplest conditional is IF, and it looks like this:

	(if predicate then else)

PREDICATE is a function that returns either true or false.  If PREDICATE returns true, then IF returns the value of THEN, otherwise it returns the value of ELSE.  For example:

	? (defun odd-or-even (x) (if (equal (mod x 2) 1) "odd" "even"))
	ODD-OR-EVEN
	? (odd-or-even 123)
	"odd"
	? (odd-or-even 12)
	"even"

Note that I've snuck two new functions in here.  MOD is the modulo operator, i.e. (mod x y) returns the remainder when X is divided by Y, and EQUAL is a predicate that returns true if its arguments are equal to each other.  (Exactly what this means is actually very complicated, but you can ignore that for now.)

IF can be chained together, like so:
	
	? (defun to-words (n)
	    (if (equal n 1)
	      "one"
	      (if (equal n 2)
	        "two"
	        (if (equal n 3)
	          "three"
	          "I can't count that high"))))
	TO-WORDS
	? (to-words 2)
	"two"
	? (to-words 123)
	"I can't count that high"

Note that when you have a lot of chained IFs then the code tends to crawl off the right side of the page.  To avoid this, you can use a different construct called MCOND, which is like a self-contained chained if.  In general, it looks like this:

	(mcond predicate1 then1 predicate2 then2 ... predicateN thenN else)

So we could write TO-WORDS like this:

	(defun to-words (n)
	    (mcond (equal n 1) "one"
	           (equal n 2) "two"
	           (equal n 3) "three"
	           "I can't count that high"))

(The reason MCOND is named MCOND is that Lisp has a similar construct named COND that, like LET, does the same thing but with more parentheses.  John McCarthy, the inventor (some would say "discoverer") of Lisp once expressed regret at having designed COND with extra, unnecessray parenthesis.  MCOND is what McCarthy would have built if he'd had it to do over again, and so it is named in his honor.)

Most programming languages also include looping constructs like FOR, WHILE and UNTIL.  You don't actually need those, because anything you can do with a loop you can with recursion (we'll get to that) but since we're working middle-out I'm going to give you a looping construct.  It's called FOR, and it is part of Ergolib, not Common Lisp.  The general syntax is:

	(for VAR in THING collect EXPRESSION)

(There are actually other things you can put in there besides COLLECT, but one thing at a time.)

We're getting a little ahead of ourselves because until we introduce lists there are not going to be many THINGs that we can iterate over, so I'll go ahead and give you one such thing, a counter:

	(counter start end [step])

The STEP is optional (as indicated by the square brackets).  So, for example:

	? (for x in (counter 10 20) collect x)
	(10 11 12 13 14 15 16 17 18 19)
	? (for x in (counter 1 10 2) collect (* x x))
	(1 9 25 49 81)

The reason FOR is cool is that you can use it to iterate over just about anything.  For example:

	? (for character in "string" collect character)
	(#\s #\t #\r #\i #\n #\g)

but we're getting a little ahead of ourselves here.

## Bunches o' functions

I'm now just going to throw a whole bag of functions at you that you can use.

### Numbers and Arithmetic

We've already met several arithmetic primitives.  Common Lisp has an exceptionally well developed numerical library, which includes infinite-precision integers, fractions, floating point numbers, and complex numbers.  This library is well described in CLHS chapter 12, so I won't reiterate it here.  Suffice it to say, if you want to do math, anything you find in CLHS chapter 12 is fair game.

### Strings

Strings are probably the most useful data structure in today's world, since people tend to use computers to do things like document processing or building web pages more than they do math.  Strings in Common Lisp are denoted by double quotes, and, like numbers, a string is its own value:

	? "This is a string"
	"This is a string"

You can glue two strings together using STRCAT.  (Note: STRCAT is part of Ergolib, not Common Lisp.)

	? (strcat "This" "that")
	"Thisthat"
	? 

You can also split a string into parts using SPLIT:

	? (split "This that and the other thing" " ")
	("This" "that" "and" "the" "other" "thing")
	? 

(SPLIT, like STRCAT, is part of Ergolib, not Common Lisp.  I'm going to stop pointing this out now.)

Note that the result of SPLIT is a list of strings.  We haven't yet met lists, so let's introduce them now:

### Lists

A list is just that: a list of things surrounded by parentheses.  The following are examples of lists:

	("This" "that" "and" "the" "other" "thing")
	
	("Another" "list" "of" "strings")
	
	(1 2.3 4/5)

That last one is, obviously, a list of different kinds of numbers.  You can mix numbers and strings in the same list:

	("A list of" 3 "different things")

That is a list of three different things.  The first and third are strings, and the second is the number 3.

Lists can also contain other lists:

	("This is a list" ("that contains" "another list"))

That is a list of two things.  The first is a string an the second is a list of two strings.

Here is another list:

	(setf x 123)

That is a list of three things.  The third thing is the number 123, but the first two things are kind of weird.  They're obviously not numbers.  They kind of look like strings, except that they are not surrounded by double-quotes.  So what are they?

SETF and X are examples of SYMBOLS.  Symbols are a fully fledged Lisp data type.  In fact, symbols are probably the most important Lisp data type after lists.  But understanding symbols is complicated, so we're going to defer that for now.

Notice, by the way, that neither symbols nor lists are self-evaluating the way strings and numbers are.  Symbols evaluate to whatever value was assigned to them by a binding construct (like SETF) and lists evaluate according to the rules of function calls, which we will discuss at some length in future chapters.  But we are getting ahead of ourselves.

There is a function that makes lists.  It's called LIST:

	? (list 1 2 3)
	(1 2 3)
	? (list "A list" (list "that contains" "another list"))
	("A list" ("that contains" "another list"))

There is a function that lets you extract an element from a list based on its index.  It's called REF:

	? (ref (list 100 200 300) 1)
	200

(NOTE: REF is actually not a function, it's a macro.  But you can safely ignore that for now.)

There is a function called SLICE that lets you take slices of either lists or strings:

	? (slice "abcdefg" 2 4)
	"cd"
	? (slice (list 1 2 3 4 5 6 7) 3 5)
	(4 5)

If you give SLICE a negative number it counts from the end:

	? (slice "abcxyz" 2 -2)
	"cx"

The last argument to slice is optional.  If you leave it out, it defaults to the length of the thing you are slicing:

	? (slice "This is a test" 5)
	"is a test"

SPLIT takes slices of either a list or a string according to the position of a target sub-string or sub-list:

	? (split "This is a test" " ")
	("This" "is" "a" "test")
	? (split (list 1 2 3 4 3 2 1) 3)
	((1 2) (4) (2 1))

The opposite of SPLIT is JOIN:

	? (join (list "foo" "baz" "bar") " ")
	"foo baz bar"

Note that although SPLIT works on either strings or lists, JOIN will always join things as if they were strings.  This is actually a bug and needs to be fixed.

The second argument to JOIN is optional.  If you leave it out, it defaults to an empty string:

	? (join (list "foo" "baz" "bar"))
	"foobazbar"

There are also three functions that let you put lists together and take them apart one element at a time.  These are called FIRST, REST and CONS.  FIRST returns the first element of a list:

	? (first (list 100 200 300))
	100

In other words, (FIRST ...) is the same as (REF ... 0).  The reason it is its own function is that taking the first element of a list is such a common thing to do that it merits having its own function.  In fact, it is so common that there are actually two more functions that do exactly the same thing.  These are called CAR and FST.  Both of these are exactly the same as FIRST, and can be used interchangeably.  CAR exists mainly for historical reasons, and FST is a function provided by Ergolib.  The rationale for adding FST to the mix will be presented later when we talk about the art of naming things.

REST is sort of the opposite of FIRST.  It returns a list that consists of everything *except* the first element of a list:

	? (rest (list 100 200 300))
	(200 300)

In other words, (REST ...) is the same as (SLICE ... 1).  Like FIRST, REST is so common it also has two doppelgangers, called CDR and RST.

CONS is the converse of both FIRST and REST.  What FIRST and REST take apart, CONS puts back together.  CONS takes an item and a list and makes a new list whose FIRST element is the item and whose REST is the list.  e.g.:

	? (cons 1 (list 2 3))
	(1 2 3)

