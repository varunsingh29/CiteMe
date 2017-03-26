CiteMe - Bash Script
===================
Given a wikipedia article as a URL, this bash script performs two tasks.

__Task 1:__ Get all lines with citations **X** ( where X is a number)

__Task 2:__ Get all the citations of a particular line.

Implemented using curl, sed, grep, regex and a little bit of magic.

----------

### __Installation__

Check out a copy of the CiteMe repository or download the `CiteMe.sh` file and execute it.
```
$ git clone https://github.com/varunsingh29/CiteMe.git
$ cd CiteMe
$ bash CiteMe.sh
```
#### __External Dependencies__
__Linux__

_None !!_

The script uses standard utilities such as `curl` `grep` `sed`  all of which are preinstalled on most flavors of Linux. However if any of the utility isn't present on your system, run the following commands

```
$ sudo apt-get install curl
$ sudo apt-get install sed
$ sudo apt-get install grep
```

__macOS__

Since macOS uses BSD sed and the script uses features of GNU sed, install GNU sed by typing
```
$ brew install gnu-sed --with-default-names
```
Update path if needed
```
$ echo $PATH | grep -q '/usr/local/bin'; [ $? -ne 0 ] && export PATH=/usr/local/bin:$PATH
$ echo a | sed ’s_A_X_i’
```
---------

### __Running__
On executing, the script will request for a wikipedia URL, for example

`Enter URL:` https://en.wikipedia.org/wiki/Marvel_Comics

```
Aye Aye Captain! Fetching the webpage for you...

Processing...
This may take a few seconds ... Go Grab a snickers!
Done !!
```
```
Choose type of query
[1]: Get lines with citation X
[2]: Get citations of a line
```
If Choice is 1
```
1
Enter citation number: 21
```
It outputs **all** the strings with that citation number. Here, 3 lines had citation [21]

> String(s): Goodman began using the globe logo of the Atlas News  Company, the newsstand-distribution company he owned, on comics cover-dated November 1951 even though another company, Kable News, continued to distribute his comics through the August 1952 issues
>
> In 1968, while selling 50 million comic books a year, company founder Goodman revised the constraining distribution arrangement with Independent News he had reached under duress during the Atlas years, allowing him now to release as many titles as demand warranted
>
> In 1969, Goodman finally ended his distribution deal with Independent by signing with Curtis Circulation Company

If Choice is 2
```
2
Enter string: Walt Disney Parks and Resorts plans on creating original Marvel attractions at their theme parks
Citation(s):  115 116 117 118
```
Since, the tool uses `grep` for searching, it can even generate all the citations with extremely small substrings. For example, here _Rosenberg sold Malibu_ is a substring of

> Three years later Rosenberg sold Malibu to Marvel on November 3, 1994, who acquired the then-leading  standard for computer coloring of comic books (developed by Rosenberg) in the process,but also integrating the Genesis Universe (Earth-1136) and the Ultraverse (Earth-93060) into Marvel's  multiverse.

```
2
Enter string: Rosenberg sold Malibu
Citation(s):  55 56 57 58 58 59 60 61
```
---------

### __Tests__
The script uses [BATS (Bash Automated Testing System)](https://github.com/sstephenson/bats)  which is a TAP- compliant testing framework for Bash.

#### __Installing BATS from source__
Check out a copy of the Bats repository. Then, either add the Bats `bin` directory to your `$PATH`, or run the provided `install.sh` command with the location to the prefix in which you want to install Bats. For example, to install Bats into `/usr/local`,
```
$ git clone https://github.com/sstephenson/bats.git
$ cd bats
$ ./install.sh /usr/local
```
Note that you may need to run install.sh with sudo if you do not have permission to write to the installation prefix.

#### __Running Tests__
Once installed, `cd` into the `Tests` directory of `CiteMe` repository and run
`$ bats TESTCASES.bats`

```
 ✓ Dunning Kruger Sample Test Case 1
 ✓ Dunning Kruger Sample Test Case 2
 ✓ Validate URL: Wrong URL
 ✗ Internet Connection Issues
   (in test file TESTCASES.bats, line 24)
     `[ "$result" == "$out" ]' failed
 ✓ Wikipedia Page with no Citations : Regular Grammar
 ✓ Type 1: Get lines which have citation X - Marvel - Multiple Citations
 ✓ Type 1: Lithium - With metacharacters in text - Single Citation
 ✓ Type 2: Get Citations of a line - Facebook - Single Citation
 ✓ Type 2: Facebook - Multiple Citation - Substring search
 ✓ Entering Citations that do not exist

10 tests, 1 failure
```
__NOTE:__ The internet connection issue test case passes when the network is disconnected or the internet is too slow

----------

### **How the task was achieved ?**

- Read the URL
	- Check if it is a valid Wikipedia URL using `grep`
- Check for internet connection using `curl`
- Modify the url and append `?action=render` to get  the HTML rendering of the entire page content.
-  Scrap of HTMl tags using `sed` and regex
- Since Wikipedia sentences either begin with a newline or a `. ` (Dot space) and have all the citations after the full stop, use `sed` to put citations before the full stop that makes it easier to extract.
- Remove all empty lines, to avoid empty lines in output.
- Find all the sentences that have citations in them using regex and extract them.
	- Sentences either start with newline or `. `
	- Read all character that are not full stop or are decimal numbers
	- Read citations of the format [:digit:], can have multiple citations together.
	- Read all characters till a full stop or a newline (`grep` by default is for single line) is encountered.
	- Remove `. ` from the beginning of extracted lines.
	- Put all these citations in a new file line by line
-  While there are lines (with citations) present in the new file
	-  Select the first line using `grep` and `head`in a variable say `$str`
	-  Store all the citation numbers in that line in a variable say `$cite` using `grep` and `sed`
	- Once stored, remove those citations from the line so that the text can be used for output
	- Delete the processed line( first line) from the file.
	- Put the citations from `$cite` and string from `$str` in a new file in the following format ` ~ All the citations ~ The string `
	- Example, the file with processed text will look like this, [(Marvel Article)](https://en.wikipedia.org/wiki/Marvel_Comics)

> ~ 1 2 3 4 5 6 ~ Characters such as Spider-Man, the Fantastic Four, the Avengers, Daredevil and Doctor Strange are based in New York City, whereas the X-Men have historically been based in Salem Center, New York and Hulk's stories often have been set in the American Southwest
>
> ~ 7 8 ~ Martin Goodman founded the company later known as Marvel Comics under the name Timely Publications in 1939
>
>  ~ 8 ~ Launching his new line from his existing company's offices at 330 West 42nd Street, New York City, he officially held the titles of editor, managing editor, and business manager, with Abraham Goodman officially listed as publisher

- Check if there are no citations, if none then return
- Ask user for type of task
- If Task 1, read citation number , and find all the lines that have that citation number present
	- Format the obtained string and prettify it for output.
-  If Task 2, read string or substring in a variable
	- Remove a fullstop if encountered in the end of the line, because to segregate the sentences, the fullstops were processed and removed.
	- Search for all the lines having that text and extract the `~ Citation ~` part and format it for output.
-  If invalid input, exit
- Ask user, if he wants to continue with more queries, if yes, loop. If no, exit
- Clean up the directory and exit.

----------
### **Pros**
- Bash, hence extremely fast.
- For a given URL, processes all citations at once, so querying is in constant time.
- Accounts for cases with multiple citations, text having regex metacharacters, and text with no citations at all.

### **Issues**
-  Should not use regex to parse HTML.
>  Entire HTML parsing is not possible with regular expressions, since
> it depends on matching the opening and the closing tag which is not
> possible with regexps.
>
> Regular expressions can only match regular languages but HTML is a
> context-free language. The only thing you can do with regexps on HTML
> is heuristics but that will not work on every condition. It should be
> possible to present a HTML file that will be matched wrongly by any
> regular expression.
[Source](http://stackoverflow.com/questions/590747/using-regular-expressions-to-parse-html-why-not)

-  Bash is not a POSIX shell. Also, won't work on other OS like Windows and macOS.
- Will not identify some lines that have texts such as __Oct. 19__ (notice the dot space character), __U.S.__ , __etc.__ (the word etcetera itself) and others since the fundamental assumption is that new sentence starts with a `. ` or a newline, so there is no way of telling if it is a new line or such abbreviations, and hence the output for a given citation number may sometimes have a partial sentence. Although, such cases are less in numbers.

-----

### __Update__

Ported this project to Python using Requests and beautifulsoup4 for cross platform support.
Link:  [CiteMePy](https://github.com/varunsingh29/CiteMePy)

-----

### __SideNote:__
Ever since I have switched to Linux (the last summer), I have always loved how unix based systems are so well-defined, simple and fast. I have been using Vim as my default editor, LaTeX to prepare most of my documents etc. Doing this project __using bash scripts__ and using tools like `sed`, `grep` has reinforced my belief manyfold. I am really glad for this opportunity.

__Bonus__ (For the love of xkcd)

![](regular_expressions.jpg "Me after this project")
