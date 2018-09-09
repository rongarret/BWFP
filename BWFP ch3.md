#Bit Wrangling for Fun and Profit (DRAFT)

## Chapter 3: The READ-EVAL-PRINT loop

So far we have talked abstractly about models of computation.  In this chapter we will see our first concrete example.  You have actually already seen it: it is the Lisp model, where you type an expression like:

	(+ 2 3)

and the computer responds with

	5

In this chapter we will make this model precise, and we will also take our first steps towards understanding how it actually works under the hood.

First, a brief review: in the previous chapters we introduced some Lisp data types, including numbers, characters, strings and lists.  We also talked about the difficulty of talking about these things in a book because of the fact that the only tool at our disposal is strings of characters.  So it becomes difficult to distinguish between, say, the list:

	(1 2 3)

and the string:

	"(1 2 3)"

Because what you are actually looking at in both cases are strings.  In the second case, the string begins and ends with a double-quote character, and in the first case it begins with an open-parenthesis and ends with a close-parenthesis.  These strings are *not* the same as the data structures they denote.  The first string denotes a list and the second string denotes a string.  And this string:

	#\"

denotes a character, specifically, a double-quote (which happens to be the character that denotes strings).

There is a Lisp function that parses strings and returns the data structures that they represent.  That function is called READ, and you can call it directly.  By default, READ reads a string from standard input, so if you just type READ it will look like the system is hung, but it's not; it is waiting for you to type something.  So, for example:

```
? (read)
"this is a string"   ; <-- This was typed in
"this is a string"   ; <-- This is the result that the READ function returns
?
```

There is a variant of READ that reads from a string passed in as an argument rather than from the standard input.  This makes is a little easier to tell what is going on from a transcript.  This function is intuitively named READ-FROM-STRING.

```
? (read-from-string "123")
123
3
? 
```

Note that READ-FROM-STRING returns *two* values.  The first is the thing that was read, and the second is the number of characters that were consumed.  Both READ and READ-FROM-STRING will only read *one* Lisp data item from the input stream and then stop.

```
? (read-from-string "(one list) (two list) (red list) (blue list)")
(ONE LIST)
10
? 
```

The full rules for how READ works are quite complicated because the Lisp reader is very powerful.  You can even customize it to read new kinds of data objects that you define.  We will eventually get to that, but first things first.  For now, here is a simplified description of what READ does that will be good enough or now:

1.  First, READ skips over all whitespace to the first non-whitespace character in the input.
2.  Next, READ looks to see if this character is one of the following:

	( ) # " '

i.e. open-paren, close-paren, hash sign, double quote or single quote.

3.  If the character is an open-paren then READ continues to read items from the input stream until it encounters a close-paren.
4.  If the character is a close-paren then READ stops reading whatever list it was reading.  If it was not reading a list, i.e. if there was no corresponding close paren, then READ signals an error.
5.  If the character is a hash sign then READ looks at the *next* character to decide what to do.  There are a lot of different possibilities here, but the only one you need to worry about at this point is the case of the next character being a backslash.  This is the case you have already encountered: this syntax designates a character, e.g. #\A.
6.  If the character is a double quote then READ reads the following characters as a string until the next double 	quote.
7.  If the character is not a special character, then Lisp tries to interpret whatever follows as a number.  If it can, then it returns that number, otherwise it returns a *symbol* whose name is whatever follows up to the next whitespace or special character.

Note that I skipped over what happens if the character is a single quote.  I'm putting that off because things are already complicated enough, and if I told what single-quote does right now you'd think I'm crazy.  (OK, OK, I'll tell you: it reads the next data item off the input stream and returns it as the second element of a list whose first element is the symbol QUOTE.  You were warned.)

If you have been experimenting with READ-FROM-STRING you will have observed that its actual behavior seems much more boring than what I have just described.  In fact, it will appear that all READ-FROM-STRING does is remove the double quotes from a string and print the result, with a few minor tweaks.  For example:

```
? (read-from-string "(this is a list)")
(THIS IS A LIST)
16
? 
```

Notice that the lower case characters all turned into upper case.  This is a historical accident.  Lisp was invented back when people interacted with computers through [teletype machines](https://en.wikipedia.org/wiki/Teleprinter).  In order to distinguish what the user had typed from what the computer had typed, all user input was done in lower case.  The reader converted symbols from lower case to upper case so that when they were printed back out they looked different than when they were typed in.  Nowadays we can use different fonts and colors to distinguish input from output, but the tradition of converting symbol case in this way is woven too deeply into Lisp culture and legacy code to easily extract.  You can do it if you want to, and you might want to try just to find out why it's not as good an idea as you might think.  Here's how you do it:

	(setf (readtable-case *readtable*) :preserve)

But if you try this you are on your own.  (The best way to get yourself out of the resulting mess at this point will be to restart Lisp.  You have been warned.)

Back to READ.  So far we have been able to get READ to produce lists, symbols, and numbers (both integers and floating point).  But watch what happens when we try to get it to produce a character:

```
? (read-from-string "#\c")
> Error: Unexpected end of file on #<STRING-INPUT-STREAM  #x302000F5EE0D>, near position 2, within "#c"
```

Youch!  What happened there?

The answer to that question has to do with an accident of history, and the fact that the ascii character set (and hence a standard keboard) only has one kind of double-quote.  So we are constrained to use the *same character* to denote both the beginning and the end of a string.  We can nest lists because we have both open parens and close parens to distinguish between the start and end of a list, but in standard ascii we don't have open quotes and close quotes, we just have one double quote.  So what do we do if we want to make a string that includes a double quote?  We can'y just type a double-quote because that would designate the end of the string!

The answer is a horrible hack that has haunted mankind since it was invented in the 1960's and will probably continue to do so until the end of civilization: if we want to put a double-quote inside a string we have to *escape* it by preceding it with yet another special character that says, "Interpret the following as a literal double quote and not as the end of a string."  The character selected to be the escape character inside strings was the backslash: \

You may recognize the backslash.  It does double-duty as the dispatch character that designates characters, like #\A.

“smart quotes”