# MDT to HTML Converter using Functional Programming

## Syntax and functionality 

- Headings : Headings are rendered when # characters occur at the beginning of a line. There can not be more than 6 # symbols, otherwise any extra # symbols are treated as text. Whenever spaces occur between #, the first contiguous sequence of # are taken to be the headings, and the rest of the # symbols are taken as text. Headings close at newline character by default. 
- Tables : A table is created when a line contains only the symbols "<<" with leading or trailing spaces. Table rows are in separate rows in the markdown file. Table data are separated by "|" symbols. There should not be an empty line in between two table rows. Tables are centered by default.  
Roughly, the syntax looks like this : 
        <pre> 
        <<
        a | b 
        c | d 
        >>
        </pre>
- Bold, Italic : Text wrapped inside ** text \*\* is rendered as bold. Text inside * text * is italicized. 
- Codeblocks : These are essentially used to display code as it is in the markdown file without any changes, including any spaces, < or > symbols. 
- Inline HTML : All html tags are unchanged. 
- Horizontal rule : A horizontal line is rendered using the \<hr\> tag whenever a line contains only "-" characters and there are atleast 3 of them. Note that there can be no spaces between these dash symbols. 
- Unordered lists : These are rendered whenever the lines start with a "-" symbol. Each such line is a new list item. 
- Paragraph : A paragraph is terminated only when we read a blank line. 

One thing to note is that essentially everything in the implementation is either a list, a paragraph, a heading, a code block, or a block quote. 

- Ordered lists : These are rendered when the line starts with a number, immediately followed by a ".", followed by a whitespace character. Each such line represents a new list item in this ordered lists. 
- Escape characters : The "\" symbol is used to read the next symbol as it is, and ignore any special meaning that it may have in the context of our markdown syntax.  
- Links : There are two types of links, one is of the form <link> and the other is of the form \[text](link). Note that there can not be spaces between ) and ]. 

#### A Note on Nesting of Lists
Lists can be nested, however we need to take care of the syntax in this case. Each list item needs to be ended with an empty line. For nested list items, we need to leave the number of lines equal to the degree of nesting of that list item. 

Bold, italic etc. can be nested inside lists, tables etc. 

## Instructions for use 
1. Place the markdown file in the same folder as the SML file
2. Compile the SML file and run the mdt2html function with a single parameter, the name of the markdown file passed as a string
3. You will get the output html file named output.html
