# Bit Wrangling for Fun and Profit

## Chapter 1.5 - How to think like a computer

Before going on with the nitty-gritty details I want to give you the 60,000-foot view of where we're heading.  Some of what is coming down the pike is going to feel like it is overwhelmingly complex, and it's helpful to have a full view of the lay of the land to allay the feeling that things are spinning wildly out of control.

Sooner or later you will become frustrated by how anal-retentive computers seem to be.  You will tell the computer to do A and the computer will instead do Q, and you will spend several hours tearing your hair out trying to figure out why it did Q instead of A and the answer will turn out to be that you left out a punctuation mark or misspelled a word or something like that and you will think to yourself, "Why can't this stupid machine just figure out what I meant and do that?"

Here's why: you are a human being, and so the way you perceive the world is deeply and fundamentally different from the way computers perceive the world.  You have eyes and ears and three other senses that provide a flood of input data to your brain, which processes all that data in ways that you are, for the most part, not consciously aware of.  All that processing is done by brain circuits that have been honed by evolution over the millennia to do amazing feats of spatial and social reasoning.  By the time all that information reaches your conscious self it has been transformed into a very rich model of the world around you.  That model is the result of a whole lot of work that your brain does on your behalf, but because it's not part of your consciousness, it seems effortless (to your conscious self).

Computers don't have the benefit of all this pre-processing (yet).  They see the world, essenially, one bit at a time (or, nowadays, 64 bits at a time).  They know nothing of shapes or letters or words or even numbers.  To a computer's "native" thought process, the following two lines:

	1234+5678
	1,234 + 5,678
	
look as different as:

	ABCDEFGHI
	AQBCDRERFQGHI

look to you.  Despite the superficial appearance that computers sometimes behave like humans, their "mental processes" are utterly foreign.  To a computer, there is no essential difference between printing out "Hello world" and "foinwonignopwe".

So how do we wrap our brains around a computer's "mental" processes?  By building what are called *models of computation*.  A model of computation is a *story*, a dramatic narrative essentially, that describes what a computer does.  There are lots of different models of computation.  They all turn out to be more or less equivalent, but they differ greatly in how well they match up with human though processes.

The main thing to keep in mind about models of computation is that at root they all do the same thing: they describe a *process* by which some *input* is *transformed* into some *output*.  There are a lot of different forms that the input and output can take.  For example, the input could be the electrical impulses produced by a keyboard when you press they keys.  Or it could be the data produced by a camera.  The output could be a pattern of dots on a screen (the most common real-world situation nowadays) or it could be a stream of data to be rendered as sound by a speaker or headphones.

Because models of computation all turn out to be equivalent, it doesn't really matter what form the input and output take if our purpose is to study computation in general.  So for most of this book we are going to use *text* as both our input and our output.  In other words, our interaction with the computer will consist of providing it with some input as text (by typing) and having the computer produce output as text.

This sounds simple enough, but it turns out that even just getting this far is highly non-trivial.  You may recall, if you have read books about ancient history, that computers used to be programmed by flipping switches or feeding the computer punched cards, and the output used to be rendered as blinking lights.  In fact, the output of modern computers are *still* "blinking lights" except that the lights are very, very small (we call them "pixels" nowadays) and there are a lot more of them on a moden computer than there were in the good old days.

This seems to be belaboring the obvious, but there's an important point here: the goal of this book is to give you a very *deep* and *complete* understanding of what goes on behind the scenes in a computer, and even just the very simple-seeming process of typing at a REPL and rendering the response actually has a lot of complexity behind it.  And we will actually encounter some of that complexity when we study unicode.

But we have to start somewhere, so for now we're going to ignore all of the machinery that makes it possible to type text on a keyboard and have text rendered on the screen.  We're just going to take it for granted that we can do that, and study how input text gets transformed into output text.  (It won't be quite as boring as it was in the olden days because some of our output text will be HTML, which we can render in more interesting ways than plain text using a web browser.)

## The essential characteristics of text

This is going to seem to be belaboring the obvious, but it will turn out to be crucially important later on.

What *is* text?  For our purposes, text is a collection of *characters* arranged in an *ordered sequence*.  A *character* is an abstract, atomic entity that can be both entered on a keyboard with a keystroke (or combination of keystrokes) and rendered on the screen as a recognizable shape (mostly).

Characters fall into four categories: letters, numbers, punctuation, and white space. It is whitespace that causes us to have to qualify "a recognizable shape" because whitespace doesn't render as a shape, it changes the spatial relationship of the renderings of other characters.  Consider the difference between:

	ABC

and

	A B C

The first line consists of three characters, "A", "B" and "C".  Note that they are orered *by convention* from left to right.  These conventions are not universal.  They are particular to the language we using to conduct this discourse: English.  If I were writing this book in Arabic, the ordering convention would go from right-to-left.  If I were writing in Chinese, the characters would be arranged vertically and ordered from top-to-bottom.

The second line consists of *five* characters, including two spaces, which are white-space characters.  Notice that the spaces do not have shapes of their own.  They just change the spatial relationship of the (non-white-space) characters on either side of them.

The point of this is to draw your attention to the fact that there are things you assume about what you are seeing because of the way the visual cirtcuitry in your brain is wired and because of your early training to read and write.  You have internalized conventions about what the shapes in front of your eyes *mean* that are not universal across human languages, and which are utterly foreign to computers.  For example, considered these two lines:

	 A B C
	A  B  C

You would probably consider those more or less equivalent (but distinct from "ABC"), while these:

	XYZQRP
	YXXQXXP

would be considered "distinct."  This is because the conventions for interpreting white space include rules like "it doesn't matter how much whitespace there is between characters, it is merely the presence of absence of white space that matters."  Or perhaps, "What matters when it comes to white space is whether the distance between the renderings of two adjacent characters exceeds some threshold."

But computers can't see.  So to a computer, these last two examples are *completely equivalent*.  The first one "looks" exactly the same (with respect to how the two lines relate to each other) as the second.

If spaces were the only white space character things would be a lot simpler.  Unfortunately, mainly for historical reasons, there are at least four different white space characters (and actually more, but four that we actually need to deal with).  These are called "space", "tab", "carriage return" (abbreviated CR) and "linefeed" (usually abbreviated LF).  These four exist for historical reasons.  There was a time when people interacted with computers using mechanical typewriters.  These had a mechanism called a *carriage*, a circular drum that carried a piece of paper and moved back and forth.  By moving the carriage and rotating the drum, the paper could be moved in two dimensions to bring and desired location into the active area where characters were printed (using hammers on which raised-type characters were embossed striking an inked ribbon).  The carriage could be advanced to the left by the width of one character using the space bar, or to the next *tab stop* using the tab key.  It could also be *returned* to its left most position in one smooth motion using a lever attached to the carriage (hence "carriage return").  When not connected to a computer, this motion was usually mechanically linked to the action of rotating the drum to move the paper up by one line.  But when connected to a computer, this mechanical linkage was disconnected to allow the carriage to be returned *without* feeding the paper up one line in order to allow overtyping of one line with another (this was considered "advanced graphics techniques" in those days).  So the carriage return and the line feed were decoupled.

Nowadays if we want graphics we just draw graphics, and so the carriage return and line feed have been conflated into a single abstract concept that we call "end of line".  The problem is that there are three different conventions in common use for using CR and LF to represent end-of-line.  Unix uses LF.  DOS and Windows use CR.  And the Web uses a sequence of CR followed by LF.

Because of this, sequences of characters that look identical to use can appear different to a computer.  For example:

	A	B
	A   B

These two lines (should) look identical, but the first line separates the A and the B using a single tab character while the second line separates them with spaces (three of them).  The conventions for rendering tab characters vary, so depending on the system you are using to render this text those lines may or may not appear exactly the same (this ambiguity is part of the problem).

In order to try to insulate ourselves from some of this complexity we are going to use a system that treats all contiguous white space as equivalent.  So one space is the same as N spaces is the same as CR or tab or LF or any combination of the above.  The only exception is when we will write literal strings, which we will designate using the usual convention of enclosing the string in "double quotes".  So the following two will be treated as equivalent:

	These two examples are equivalent.

and

	These   two examples
	  are  equivalent.

but the following two are not:

	"These two examples are different."

and

	"These two examples
	are different"

The following two are also different:

	These two examples are different.

and

	These two exam ples are diff erent.

## Numbers

Computers were originally invented to do math, specifically arithmetic.  Again because of our early training we look at something like this:

	12 + 45 = 57

and it appears trivial.  But it wasn't trivial when you first learned it, and it isn't trivial for a computer either.  What is important to understand is that there is a difference between 12 and 45 and 57 and "12" and "45" and "57".  That is, there is a difference between the *number* twelve and the *rendering* of that number as a sequence of the two *characters* 1 and 2.

It just so happens that all humans use the same number system, so the range of possible ways to express numbers is not quite so apparent as the range of possible ways to express text.  But in fact the range of possible ways to express numbers is astonishingly broad, and we will be diving into those weeds in a future chapter.  The choice of how to represent numbers can have major impacts on the performance and correctness of a program.  In fact, a significant proportion of today's security problems can be ascribed to poor design choices in the representations of numbers.

A classic source of confusion among new programmers is this apparent anomaly:

	? (+ 0.1 0.1 0.1 0.1 0.1 0.1)
	0.6
	? (+ 0.1 0.1 0.1 0.1 0.1 0.1 0.1)
	0.70000005
	? 

The reason this happens is because the way computers typically represent fractions (floating point) doesn't permit an exact representation of one tenth.  On the other hand, if we represent numbers differently (as fractions, for example) then, as we have already seen, we can get the exact answer that we would naively expect.

One could fill multiple books with nothing but different techniques to do different kinds of mathematical operations on computers.  People make their careers studying nothing else.  We will just barely scratch the surface (and even that only much later) but if you want to catch a glimpse of the possibilities take a look at [this](http://www.mrob.com/pub/perl/hypercalc.html).

## Hierarchical data structures

It turns out that a few very simple operations directly on text are all you need to compute anything.  But we can get a lot of leverage out of layering abstractions like numbers on top of these basic operations.  The single most important abstraction that has ever been invented is the *heirarchical data structure*.  A data structure is a collection of data.  We have already met one data strucutre, the string, which is an ordered collection of characters.  (Numbers actually turn out to be data structures too.)  What distinguishes a *hierarchical* data structure is that it can contain instances of itself as members.

The canonical example of a hierarchical data structure is the *list*, which is usually written as a sequence of elements surrounded by parentheses:

	(1 2 3)

is a list of three numbers.

	(1 ("2" "3") 4)

is a list of three elements, two of which are numbers, and one of which is a list of two elements, both of which are strings.

There are many other kinds of hierarchical data structures.  For example, there are *vectors*, which are kind of like lists, but with some important differences under the hood.  There are *trees* which are very much like lists but just viewed from a different perspective.

There are also important data structures like quad-trees and hash-tables.  All of these can be viewed as instances of a more general concept, the *abstract associative map*, which can, in turn, be viewed as a special case of a *function*.  Because everything can ultimately be modelled as a function, there is an entire branch of programming (called, appropriately enough, "functional programming") that studies how to write programs using (mostly) nothing but functions.  We'll get to that eventually.

## Road map

So the lay of the land is basically this: we're going to start by typing text at a computer, and it will type text back.  We will use that text to represent useful abstract entities like numbers.  Because we are going "middle out" we will use a lot of complicated machinery like arithmetic and web servers before we actually come to an understanding of how they work.  We will eventually come around to close all the gaps.

The general course of action to "close the gaps" will be start by writing little programs that translate strings of text into abstract data types.  These are called "parsers".  We will, of course, be using a parser from the beginning, and so this might seem a little bit like cheating.  But we will eventually close the gap sufficiently that you could, if you had to, write a parser from scratch without using an already existing parser to do it.

We will then go on to describe how the inner workings of computations happen in general.  It is a rather surprising result that this can be done at all.  It is even more surprising that when you do it the right way, it turns out to be relatively simple (considering the vast power of the resulting artifacts).  There are, it turns out, "universal functions" which can compute anything.  One of these is a function called EVAL, which can be written in just a few dozen lines of code (if you use the right conventions).

The third phase will be to show how universal functions are actually realized in practice.  When we first write EVAL it will be simple, but slow, and it will use a lot of machinery behind the scenes that we didn't build.  Making EVAL practical to use on real problems makes it a lot more complicated, but this complexity can be managed if you understand the purposes that the various layers of complexity are serving, and that at the core of it all is just a small handful of very simple concepts.

The advantage to this approach over, say, just learning how to wield a particular programming language is that, like EVAL, it is *universal*.  If you come to a deep understanding of the core concepts, learning just about anything else in computer science becomes that much easier because you can start by mapping it onto one of the core concepts that you now have a deep understanding of.  Moreover, you will no longer be as dependent on others to build tools for you.  If there is, for example, something you don't like about a particular programming language or paradigm, you can change it.  In fact, a big part of our course of study will be designing and implementing new programming constructs.

But we have to start somewhere.
