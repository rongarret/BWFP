# Bit Wrangling for Fun and Profit

### DRAFT July 2015

## Introduction

On October 11, 2000 the Microsoft Press published one of the most under-appreciated technical books ever written.  It is called "Code: The Hidden Language of Computer Hardware and Software" and it gives you a more or less complete understanding of how you get from switches and transistors to computers.

What Petzold's book did for hardware, this one aims to do for software.  By the time you get to the end of this book you should be able to write at least a toy version of every part of the software stack (with the possible exception of an operating system kernel, which would require a book of its own).

Unlike Petzold, who took a strictly bottom-up approach, I am going to bow to the modern demand for instant gratification by taking a "middle-out" approach.  Bottom-up worked for Petzold because his book, despite being accessible and engaging, is nonetheless theoretical.  Petzold's book tells you everything you need to know to build your own microprocessor out of relays, or even Legos, but actually carrying out such a project would require truly heroic effort.  Some people have done it, but it's not for everyone.

Software, by way of contrast, is potentially accessible as a practical matter.  You don't need to be able to solder or use machine tools.  All you have to be able to do to build software is type, and there's a vast array of free tools to build on top of.  To understand how they work we will go through the process of re-inventing some of these wheels, but we don't have to deny ourselves the use of these tools until we've learned how to build them.

On the other hand, going strictly "top-down" is not a good idea.  "Top down" in this case would mean starting with some sort of fully functional application and dissecting it to see how it was put together.  The problem with this approach is that fully functional software applications are very, very complicated, and fully dissecting even one of them can be overwhelming if you've never done it before.  The point of this book is to make a task like that less overwhelming, but I don't want to just throw you straight into the deep end.  (You are, of course, more than welcome to throw yourself in and dig through the code for your favorite open-source application yourself, and if you are so inclined I don't want to discourage you.  But I don't think that's the best way to make progress initially.)

Instead, this book takes a "middle-out" approach.  We're going to start with just enough infrastructure to build a simple web application.  (Lesson 1 is simply going to be getting that infrastructure set up.)  Then we're going to do two things in parallel: dig into the infrastructure to see how it works under the hood, and use it to build more sophisticated applications.

The infrastructure we're going to use is a collection of libraries written by various people (including the author of this book) in a programming language called Common Lisp.  The reason for using Common Lisp is that it hits a "sweet spot" for the task at hand, namely, learning how to write code.  On the one hand, Common Lisp is an extremely flexible programming language, arguably the most flexible ever invented.  Every programming paradigm ever invented is either part of Common Lisp, or can be easily added via macros and reader macros.  Furthermore, Common Lisp code is easily inspected and incrementally compiled, making the debug cycle very, very fast.  This is crucial when you're learning to code (to say nothing of being awfully handy -- some would say indispensable -- for writing industrial-strength code efficiently).  Furthermore, Common Lisp can be (and usually is) compiled to native code, so it runs fast compared to interpreted languages like Python and Ruby.

Finally, Common Lisp is a dialect of Lisp, which is the single most influential programming language ever invented (some would say it was "discovered" rather than invented, it's that fundamental).  Understanding Lisp is like understanding the fundamental physics of software.  So despite the fact that it's not a very popular language (though this is slowly changing too) it is a huge mental lever.  If you understand Lisp, learning other languages becomes much, much easier.

This book is about programming, so I am going to assume that you already have some basic skills.  I am going to assume that you know how to use a web browser and a search engine.  I am going to assume that you know how to install and run software on your machine, and how to use a terminal.  The infrastructure we are going to use runs best on a Macintosh, but it's also possible to do this on a Linux or Windows machine as well.  But the current draft of the book assumes you're running on a Mac.

On the other hand, I am not going to assume that you know anything at all about programming, so if you have written code before you may find some of the preliminary stuff to be a little too simple, perhaps even condescending.  Trust me, things will get more challenging.

# Lesson 1:

The first step is to get set up with the infrastructure we're going to use.  The core of this infrastructure is an implementation of Common Lisp called Clozure Common Lisp (CCL).  You can find it [on the Clozure site](http://ccl.clozure.com) or [the Mac App Store](https://itunes.apple.com/us/app/clozure-cl/id489900618).

Either version will work.  You'll learn more if you get the source code from the Clozure site and build it yourself, but walking you through that process is beyond the scope of this chapter, so if you have trouble or just want to get on with it, use the App Store version.

You will also need a copy of a library called Ergolib, which can be found [on github](https://github.com/rongarret/ergolib).

If you know how to use git (and you should learn how to use git, though that, too, is beyond the scope of this chapter) then you should use it to get ergolib.  Otherwise you can just download a zip file using the link on the right side of the github page.

So I presume you have managed to get yourself to the point where you can run CCL.  It will open with a single window, which will be called "Listener".  In that window you should see something resembling the following:

	Welcome to Clozure Common Lisp Version 1.10-store-r16266  (DarwinX8664)!
	? 

This will be your home for the next several weeks (or months or years depending on how much you end up getting into this).  The basic operation of the Listener is very simple: you type something at it.  The computer will process whatever you type to produce a result, which it will then be printed out for you.  For example, try typing the number 123.  The result should look like this:

	Welcome to Clozure Common Lisp Version 1.10-r16304M  (DarwinX8664)!
	? 123
	123
	? 

Now try typing 123+456.  You should see the following:

	? 123+456
	> Error: Unbound variable: 123+456
	> While executing: CCL::TOPLEVEL-EVAL, in process Listener(5).
	> Type cmd-/ to continue, cmd-. to abort, cmd-\ for a list of available restarts.
	> If continued: Retry getting the value of 123+456.
	> Type :? for other options.
	1 > 

This result may surprise you, and we will shortly get to an explanation of why this happened.  But for now you just need to learn what to do when you end up in a situation like this, because while this is the first time you will have encountered an error I promise you it will not be the last.

What has happened here is that (obviously) you have encountered an error, and the Listener is now in a mode designed to help you diagnose and fix the problem.  We will eventually learn how to use this mode, which is called "the debugger".  You can tell you are in the debugger mode because the prompt now has a number in front of it (i.e. "1 >" instead of "? ").  If you ever do something that generates an error inside the debugger you will get a "nested" debugger whose prompt start with "2 >" instead of "1 >".  In fact, you can try that now if you like.

For now the only thing I'm going to teach you about the debugger is how to get out of it.  There are three ways.  The first is to type [cmd-.], i.e. hold down the CMD key and type a period.  (If you read through all the gobbledygook that the debugger printed out you will see this presented as one of the options.)  The second is to type [ctrl-d] (i.e. hold down the ctrl key and type the letter d).  The reason this way is important is that in future lessons we will be running CCL from a command line rather than as a standalone application, and when you're running that way CMD-. doesn't work, so you have to use [ctrl-d].  The third way is to type the word "pop" and hit the return key.  You can use whichever of these three methods you prefer.

Now that you know how to get yourself out of the debugger, we can start actually interacting with Lisp.  First, some terminology: the process of looking at what you typed and producing a result from that is called "evaluation".  So what the listener does is READ some text that you type in, EVALUATE that text to produce a result, and PRINT the result.  And it does this in a loop, so this process is called a READ-EVAL-PRINT Loop or REPL.  So the Listener is a window that runs a REPL.  The words REPL and Listener are more or less synonymous and are often used interchangeably.

Interesting things happen in all three phases of this process, but evaluation is by far the most interesting and important so we will dig into that first.  As we have already seen, when you type a number the result is just that number.  Likewise with strings enclosed in double-quotes:

	? "foo"
	"foo"
	? 

But mathematical expressions like 123+456 produce errors, as we saw above.  This is because the REPL is running Lisp, and Lisp has a weird syntax compared to other languages.  If you want to add 123 and 456 in Lisp you have to do this:

	? (+ 123 456)
	579
	? 

This is the point at which most people -- especially those who have experience in other programming languages -- recoil in horror and say, "What is this bogosity?  If this stupid system isn't smart enough to know that when I type 123+456 I want to add two numbers it's not worth bothering with.  Lisp is obviously some pie-in-the-sky ivory-tower bullshit."

At this point I am going to have to ask you to simply suspend your disbelief and trust me when I tell you that there is in fact a very good reason why Lisp has the weird syntax that it does.  But that reason won't become apparent until later.  In fact, it will become most apparent when we get to the point where we write a parser for the more traditional infix syntax and embed it into our Lisp system.

Wait, what? you might be asking yourself.  It's possible to embed traditional infix syntax in Lisp?  Yes, it is.  In fact, this capability is built in to the ergolib infrastructure, and by the end of this lesson I'll show you how to access it.  But I promise you that by the time we get to that point, you won't want to any more.

In order to give some preliminary motivation for why Lisp's syntax is the way it is, we are going to write our first program.  It will be exactly one line long:

	(defun sum-of (x y) (+ x y))

Go ahead and type that in to the REPL.  The result should look like this:

	? (defun sum-of (x y) (+ x y))
	SUM-OF
	? 

Now you can do this:

	? (sum-of 123 456)
	579

Obviously this program isn't very interesting or useful, but it illustrates a very important point.  Writing (sum-of 123 456) feels a little more intuitive than (+ 123 456).  It reads more like English: "The sum of 123 and 456 is 579."

You can also do more complicated things, e.g.:

	? (sum-of (sum-of 1 2) 3)
	6
	? (sum-of (sum-of (sum-of 1 2) (sum-of 3 4)) pi)
	13.141592653589793D0

Notice that we didn't have to do anything to define PI, it's built-in to Common Lisp.

OK, so all this is reading somewhat intuitively, but it still seems like an awful lot of trouble and typing to go through just to add numbers.  It seems like it would be a lot easier to be able to write:

	1+2+3+4+pi

We can't write that in Lisp (yet) but we can do this instead:

	? (+ 1 2 3 4 pi)
	13.141592653589793D0

(Note that now we have to use the built-in "+" function and not our SUM-OF function because we wrote SUM-OF in a way that it can only handle two numbers at a time.  We will eventually learn how to write our own functions that can handle arbitrary numbers of numbers, but first things first.)

So let's take a very brief tour of some of the things we can do that are built-in to Common Lisp.  As we have already seen, we can add numbers.  We can also multiply them:

	? (* 3 4)
	12
	? (* 3 4 5 6 7)
	2520

And subtract them:

	? (- 100 10)
	90
	? (- 100 10 20)
	70

And divide them:

	? (/ 10 5)
	2
	? (/ 10 pi)
	3.183098861837907D0
	? (/ 10 3)
	10/3

Notice that when you divide two integers that don't divide evenly the result is a fraction!

We can take the square roots of numbers:

	? (sqrt 25)
	5
	? (sqrt pi)
	1.7724538509055159D0

We can even take the square roots of negative numbers:

	? (sqrt -1)
	#C(0 1)

Complex numbers, like fractions, are built-in to Common Lisp.

If you want to explore the range of capabilities that are built in to Common Lisp, this is the [official reference](http://www.lispworks.com/documentation/HyperSpec/Front/).

(Well, OK, it's not the *official* reference.  The official reference is the ANSI Common Lisp spec, but the on-line hyperspec is essentially identical.)

So let's write our first non-trivial function.  This will compute the square root of the sum of the squares of two numbers:

	(defun rsq (x y) (sqrt (+ (* x x) (* y y))))

RSQ stands for Root of the Sum of the sQuares.

Try it:

	? (defun rsq (x y) (sqrt (+ (* x x) (* y y))))
	RSQ
	? (rsq 3 4)
	5

You may have noticed that when you type in Lisp expressions that the Listener window will automatically highlight matching pairs of parentheses, which makes balancing them a lot less annoying than it otherwise might be.

Exercise: using the mouse, place the cursor on a close-paren.  Now double-click.

So far you have been typing everything directly into the Listener window.  For writing real code we're going to want to type the code into an editor window so we can save our work.  To open an editor window, select FILE->NEW.

Now do the following:

1. Type (or cut-and-paste) the code for RSQ into the editor window and save it.

2. Place the cursor at the end of this line of code.

3. Press the ENTER key (NOT the RETURN key) on your keyboard.

	Notice that the Listener responds with RSQ.  Pressing ENTER in an editor window sends the "current form" to the Listener to be evaluated.

	Now do this:

4. Save the window to a file.

5. Close the window.

6. Type "RSQ" into the Listener BUT NO NOT HIT RETURN.  Instead, hit [option-.] i.e. hold down the OPTION key and type a period.  (This gesture is called "meta-point" in the Lisp world.)

	Notice how the file where RSQ is defined is magically re-opened.

	Now do this:

7. Delete RSQ and instead type SQRT, then meta-point.

The result should be a window full of Lisp code.  The name of the window should be l0-float.lisp, and the cursor should be sitting on a line of code that looks like this:

	(defun sqrt (x &aux a b)

followed by a whole bunch of other stuff.  What you are looking at is the actual code for the SQRT function built-in to Common Lisp.  Try repeating this process by putting the cursor on the name of any other function mentioned in SQRT (or anywhere else in that window) and typing [option-.].  You can explore the entire CCL code base this way (and by the time you get to the end of this book you will be able to understand nearly all of it, and even modify it to suit your own needs and desires!

But for now, let's build out first web page.  To do that we're going to have to go beyond the bounds of what is built in to Common Lisp and use some of the infrastructure in Ergolib (remember Ergolib?  It's the other thing you downloaded along with CCL at the beginning of this chapter.)

There are two ways to load Ergolib.  The easiest is to go into the Ergolib folder and double-click on the file "init.lisp".  That should open that file in CCL.  You now need to run all of the code in that file.  As always, there are multiple ways to do this:

1.  You can select "Execute All" from the "Lisp" menu in CCL.

2.  You can select all of the text in the file, either with the mouse or by typing [cmd-a] and press ENTER (NOT RETURN!)

The second way to load Ergolib is to type the following into the Listener:

(load "/path-to-ergolib/init.lisp")

where, of course, you have to replace 'path-to-ergolib' with (obviously) the path to ergolib.

If you opened init.lisp in an editor window you can close it now.

Now in the Listener, type:

	(require :ql)

[Don't leave out the colon.  The reason for it will be explained later.]

What this will do is load a gadget called QuickLisp, which will automatically download and install a wide array of third-party libraries from the web as they are needed.  (You can find more information about QuickLisp at quicklisp.org.)

Then:

	(require :webutils)

The first time you do this it will take a while because QuickLisp will download a whole bunch of stuff.  But that only has to happen once.  Subsequent times will be much faster.

Now:

	(defpage "/test" (:h1 "Hello world"))

	(ensure-http-server 1234)

Now point your browser to http://localhost:1234/test

Congratulations, you have just written your first web application in Lisp!
