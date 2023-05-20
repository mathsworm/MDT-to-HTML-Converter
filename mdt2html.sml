fun readFile(filename : string) = 
    TextIO.openIn filename


fun checknum (digits) = 
    if List.length digits = 0 then 
        true
    else if Char.ord(hd digits) >= 48 andalso Char.ord(hd digits) <= 57 then 
        checknum (tl digits)
    else 
        false


fun getStringUpto (line, symbol, curr_ans) = 
    if hd line <> symbol then 
        getStringUpto (tl line, symbol, hd line :: curr_ans)
    else 
        (curr_ans,tl line)


fun removeSpaceHelper (line,curr_ans) = 
    if List.length line = 0 then 
        curr_ans
    else if hd line <> #" " then 
        removeSpaceHelper (tl line, hd line :: curr_ans)
    else 
        removeSpaceHelper (tl line, curr_ans)


fun removeSpace (line) = 
    removeSpaceHelper (line,[])


fun removeInitSpace (line) = 
    if hd line = #" " then 
        removeInitSpace (tl line)
    else 
        line


fun countSpaceHelper (line, count) =
    if List.length line = 0 then
        count
    else if hd line = #" " then 
        countSpaceHelper(tl line, 1 + count)
    else if hd line = #"\t" then 
        countSpaceHelper(tl line, 4 + count)
    else 
        count


fun countSpace (line) =
    countSpaceHelper(line,0)


fun insertUptoNewLine (line,ans) = 
    if hd line = #"\n" then 
        ans
    else if hd line = #"<" then 
        insertUptoNewLine (tl line,  List.rev (String.explode "&lt;") @ ans)
    else if hd line = #">" then 
        insertUptoNewLine (tl line,  List.rev (String.explode "&gt;") @ ans)
    else 
        insertUptoNewLine (tl line, hd line :: ans)

fun removeNumber (line) = 
        if Char.ord(hd line) >= 48 andalso Char.ord(hd line) <= 57 then
            removeNumber (tl line)
        else 
            tl line 

fun processHRHelper (line) = 
    if List.length line = 1 then 
        true
    else if hd line <> #"-" then 
        false
    else 
        processHRHelper (tl line)


fun processHR (line) = 
    if List.length line < 4 then 
        false
    else 
        processHRHelper (line)
    

fun processEOLN (line,ans,stack,table) = 
    if hd stack = "h1" then
        processEOLN(line, (#">")::(#"1")::(#"h")::(#"/")::(#"<")::ans, tl stack,table)
    else if hd stack = "h2" then
        processEOLN(line, (#">")::(#"2")::(#"h")::(#"/")::(#"<")::ans, tl stack,table)
    else if hd stack = "h3" then
        processEOLN(line, (#">")::(#"3")::(#"h")::(#"/")::(#"<")::ans, tl stack,table)
    else if hd stack = "h4" then
        processEOLN(line, (#">")::(#"4")::(#"h")::(#"/")::(#"<")::ans, tl stack,table)
    else if hd stack = "h5" then
        processEOLN(line, (#">")::(#"5")::(#"h")::(#"/")::(#"<")::ans, tl stack,table)
    else if hd stack = "h6" then
        processEOLN(line, (#">")::(#"6")::(#"h")::(#"/")::(#"<")::ans, tl stack,table)      
    else if hd stack = "blockquote" then
        processEOLN(line, List.rev (String.explode "</blockquote>") @ ans, tl stack,table)  
    else if hd stack = "td" then (*keep last priority ?*)
        processEOLN(line, List.rev (String.explode "</td>") @ ans, tl stack,table) 
    else if hd stack = "tr" then 
        processEOLN(line, List.rev (String.explode "</tr>") @ ans, tl stack,table) 
    else
        (tl line,#" " :: #"\n" :: #" " :: ans,stack,table)


fun checkOL (line) = 
    let 
        val words = String.tokens(fn c => c = #" ") line
        val firstword = hd words
        val chars = List.rev (String.explode firstword)
    in 
        if hd chars <> #"." then 
            false
        else if checknum (tl chars) then 
            true
        else 
            false
    end


fun processWord(word, ans, stack,table) =
    if List.length word = 0 then (word,ans,stack,table)
    else if Char.ord (hd word) =  92 then  (* the character is a \ *)
        processWord(tl (tl word), hd (tl word)::ans, stack,table)

    else if List.length word >= 2 andalso hd word = #"*" andalso hd (tl word) = #"*" andalso hd stack = "bold" then 
        processWord(tl (tl word), (#">")::(#"b")::(#"/")::(#"<")::ans, tl stack,table)

    else if List.length word >= 2 andalso hd word = #"*" andalso hd (tl word) = #"*" then 
        processWord(tl (tl word), (#">")::(#"b")::(#"<")::ans, "bold"::stack,table)

    else if hd word = #"*" andalso hd stack = "italic" then 
        processWord(tl word, (#">")::(#"i")::(#"/")::(#"<")::ans, tl stack,table)

    else if hd word = #"*" then 
        processWord(tl word, (#">")::(#"i")::(#"<")::ans, "italic"::stack,table)

    else if hd word = #"|" andalso hd stack = "td" then
        processWord(tl word, List.rev (String.explode "</td> <td>") @ ans, stack,table)

    else if hd word = #"\n" then
        processEOLN(word,ans,stack,table)

    else if List.length word > 5 andalso hd (word) = #"<" andalso hd  (tl word) = #"h" andalso hd  (tl (tl word)) = #"t" andalso hd  (tl (tl (tl (word)))) = #"t" andalso hd (tl (tl (tl (tl (word))))) = #"p" then 
        let 
        val link_line = getStringUpto (tl word, #">",[])
        val link = #1 link_line
        val line = #2 link_line

        val ans1 = List.rev (String.explode "<a href = \"") @ ans
        val ans2 = link @ ans1
        val ans3 = List.rev (String.explode "\">") @ ans2
        val ans4 = link @ ans3
        val ans5 = List.rev (String.explode " </a>") @ ans4
        in 
        processWord (tl line, ans5, stack, table)
        end

    else if List.length word >= 1 andalso hd word = #"<" then 
        processWord(tl word, hd word::ans, stack,table)

    else if hd word = #"[" then 
        let 
        val x_ = word
        val link_line = getStringUpto (tl word, #"]",[])
        val link_text = #1 link_line
        val ending_bracket = #2 link_line
        in 
        if List.length ending_bracket > 5 andalso hd (ending_bracket) = #"(" andalso hd  (tl ending_bracket) = #"h" andalso hd  (tl (tl ending_bracket)) = #"t" andalso hd  (tl (tl (tl (ending_bracket)))) = #"t" andalso hd (tl (tl (tl (tl (ending_bracket))))) = #"p" then             
            let
            val link_line_2 = getStringUpto (tl ending_bracket, #")",[])
            val link_text_2 = #1 link_line_2
            val ending_bracket_2 = #2 link_line_2   
            val ans1 = List.rev (String.explode "<a href = \"") @ ans
            val ans2 = link_text_2 @ ans1
            val ans3 = List.rev (String.explode "\">") @ ans2
            val ans4 = link_text @ ans3
            val ans5 = List.rev (String.explode " </a>") @ ans4  
            in
            processWord (tl ending_bracket_2, ans5, stack, table)
            end
        else 
            processWord(tl word, hd word::ans, stack,table)
        end 
    else 
        processWord(tl word, hd word::ans, stack,table)


fun processHeading_iter (line, ans, stack, table, i) =
    if i = 6 then 
        processWord(line, (#">")::(#"6")::(#"h")::(#"<")::ans, "h6"::stack, table)
    else if i = 0 andalso hd line <> #"#" then
        processWord(line,ans,stack,table)
    else if hd line <> #"#" then 
        processWord(line, (#">")::(Char.chr(i+Char.ord(#"0")))::(#"h")::(#"<")::ans, String.implode([#"h",Char.chr(i+Char.ord(#"0"))])::stack,table)
    else if hd line = #"#" then 
        processHeading_iter (tl line, ans, stack,table, i+1)
    else (*ye change karna hai??*)
        processWord(line, ans, stack,table)


fun processHeading (line, ans, stack,table) = 
    processHeading_iter(line, ans, stack, table,0)


fun processBlockquote (line,ans,stack,table) = 
    if hd line = #">" then
        processBlockquote (tl line,List.rev (String.explode "<blockquote>") @ ans,"blockquote"::stack,table)
    else if hd line = #" " then
        processBlockquote (tl line,ans,stack,table)
    else 
        processHeading (line,ans,stack,table)
    

fun processCodeblock (line,ans,stack,table) =
    let 
    val ans1 = List.rev (String.explode "<pre> <code> ") @ ans
    val ans2 = insertUptoNewLine (line,ans1)
    val ans3 = List.rev (String.explode "</code> </pre> ") @ ans2
    in 
    (line,#"\n"::ans3,stack,table)    
    end


fun processUL (line,ans,stack,table) = 
    if hd stack <> "ul" then 
        processWord ((tl line), List.rev (String.explode "<ul> <li> <p>") @ ans, "p" :: "ul" :: stack,table)
    else 
        processWord ((tl line), List.rev (String.explode "<li> <p> ") @ ans, "p" :: stack,table)


fun processOL (line,ans,stack,table) = 
    if hd stack <> "ol" then 
        processWord ((removeNumber line), List.rev (String.explode "<ol> <li> <p>") @ ans, "p" :: "ol" :: stack,table)
    else 
        processWord ((removeNumber line), List.rev (String.explode "<li> <p> ") @ ans, "p" :: stack,table)


fun processEmptyLine (line,ans,stack,table) = 
    if hd stack = "ul" then 
        (line, List.rev (String.explode "</ul>") @ ans, tl stack, table)
    else if hd stack = "ol" then 
        (line, List.rev (String.explode "</ol>") @ ans, tl stack, table)
    else if hd stack = "p" then 
        (line, List.rev (String.explode "</p>") @ ans, tl stack, table)
    else 
        (line, List.rev (String.explode "") @ ans, stack, table)


fun processLineCombined (line,ans,stack,table) = 
    let
        val nospace = List.rev (removeSpace(String.explode line))
        val words = String.tokens(fn c => c = #" ") line
    in
        if removeInitSpace (String.explode line) = [#"\n"] then 
            processEmptyLine (String.explode line, ans, stack, table)     
        
        else if processHR (String.explode line) then 
            ([#"\n"],List.rev (String.explode "<hr>") @ ans,stack,table)

        else if countSpace (String.explode line) > 7 then
            processCodeblock (removeInitSpace (String.explode line),ans,stack,table)

        else if hd ( removeInitSpace (String.explode line)) = #"-" then 
            processUL (removeInitSpace (String.explode line), ans, stack, table)

        else if checkOL(String.implode(removeInitSpace (String.explode line))) then 
            processOL (removeInitSpace (String.explode line), ans, stack, table)

        else if List.length nospace = 3 andalso hd nospace = #"<" andalso hd (tl nospace) = #"<" then
            ([#"\n"], List.rev (String.explode "<center> <table border = \"1\">") @ ans, "table"::stack,true)

        else if List.length nospace = 3 andalso hd nospace = #">" andalso hd (tl nospace) = #">" then
            ([#"\n"], List.rev (String.explode "</table> </center>") @ ans, tl stack, false)

        else if table = true then 
            processBlockquote (String.explode line,List.rev (String.explode "<tr> <td>") @ ans, "td"::"tr"::stack,table)
        
        else if hd stack <> "p" andalso hd stack <> "ul" andalso hd stack <> "ol" then 
            processBlockquote (String.explode line,List.rev (String.explode "<p> ") @ ans, "p"::stack,table)

        else
            processBlockquote (String.explode line,ans,stack,table)
    end


fun readLine(file : TextIO.instream) = 
    let
        val check = TextIO.endOfStream(file)
        val line1 = TextIO.inputLine(file)
        val line = if check then "" else valOf(line1)
    in
    if check
    then
    []
    else
    line::readLine(file)
    end


fun processFile (lines, curr_ans, stack,table) = 
    if List.length lines = 0 then 
        curr_ans
    else
        let 
        val processedLine = processLineCombined(hd lines,curr_ans,stack,table) 
        in
        processFile (tl lines, #2 processedLine, #3 processedLine, #4 processedLine)
    end


fun mdt2html (filename) = 
    let
        val out = TextIO.openOut("output.html")
        val ans = processFile (readLine(readFile (filename)),[],["a"],false)
        val final_ans = String.implode (List.rev ans)
        val _ = TextIO.output(out, final_ans)
        val aaaa = TextIO.closeOut (out)
    in 
        final_ans
    end