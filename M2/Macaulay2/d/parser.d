--		Copyright 1994 by Daniel R. Grayson
use tokens;
use lex;

export parseRR(s:string):RRorNull := (			    -- 4.33234234234p345e-9
     prec := defaultPrecision;
     overflow := false;
     ss := new string len length(s) + 1 do (		    -- we add 1 to get at least one null character at the end
     	  inPrec := false;
	  foreach c in s do (
	       if c == 'p' then (
		    inPrec = true;
		    prec = ulong(0);
		    )
	       else if inPrec then (
		    if isdigit(c) then (
			 if !overflow then (
			     newprec := 10 * prec + (c - '0');
			     if newprec < prec
			     then overflow = true
			     else prec = newprec)
			 )
		    else (
			 inPrec = false;
		    	 provide c;
			 )
		    )
	       else (
		    provide c;
		    ));
	  while true do provide char(0);
	  );
      if overflow then RRorNull(null())
      else RRorNull(toRR(ss, prec)));
parseError := false;
parseMessage := "";
utf8(w:varstring,i:int):varstring := (
     -- this code appears twice
     if (i &     ~0x7f) == 0 then w << char(i) else
     if (i &    ~0x7ff) == 0 then w << char(0xc0 | (i >> 6)) << char(0x80 | (i & 0x3f)) else
     if (i &   ~0xffff) == 0 then w << char(0xe0 | (i >> 12)) << char(0x80 | ((i >> 6) & 0x3f)) << char(0x80 | (i & 0x3f)) else
     if (i & ~0x1fffff) == 0 then w << char(0xf0 | (i >> 18)) << char(0x80 | ((i >> 12) & 0x3f)) << char(0x80 | ((i >> 6) & 0x3f)) << char(0x80 | (i & 0x3f))
     else w
     );

export hexvalue   (c:char ):int  := (
     if c >= '0' && c <= '9' then c - '0' else
     if c >= 'a' && c <= 'f' then 10 + (c - 'a') else
     if c >= 'A' && c <= 'F' then 10 + (c - 'A')
     else 0						    -- we don't expect this to happen
     );
export hexvalue   (c:int ):int  := hexvalue(char(c));

export parseInt(s:string):ZZ := (
     i := zeroZZ;
     n := length(s);
     if n == 1 then i = toInteger(s.0 - '0')
     else if s.0 == '0' && (s.1  == 'b' || s.1 == 'B') then
     	  for j from 2 to n - 1 do i = 2 * i + (s.j - '0')
     else if s.0 == '0' && (s.1 == 'o' || s.1 == 'O') then
     	  for j from 2 to n - 1 do i = 8 * i + (s.j - '0')
     else if s.0 == '0' && (s.1 == 'x' || s.1 == 'X') then
     	  for j from 2 to n - 1 do i = 16 * i + hexvalue(s.j)
     else foreach c in s do (
	  if c == '\"'
	  then nothing
	  else i = 10 * i + (c - '0')
	  );
     i);

export parseString(s:string):string := (
     parseError = false;
     v := newvarstring(length(s)-2);
     i := 1;
     while true do (
	  if s.i == '\"' then break;
	  if s.i == '\\' then (
	       i = i+1;
	       c := s.i;
	       if c == 'n' then v << '\n'
	       else if c == '"' then v << '"'
	       else if c == 'r' then v << '\r'
	       else if c == 'a' then v << char(7)
	       else if c == 'b' then v << '\b'
	       else if c == 't' then v << '\t'
	       else if c == 'v' then v << char(11)
	       else if c == 'f' then v << '\f'
	       else if c == 'e' then v << char(27)
	       else if c == 'E' then v << char(27)
	       else if c == '\\' then v << '\\'
	       else if c == 'u' then (
		    i = i+4;
		    utf8(v, ((hexvalue(s.(i-3)) * 16 + hexvalue(s.(i-2))) * 16 + hexvalue(s.(i-1))) * 16 + hexvalue(s.i)))
	       else if c == 'x' then (
		    i = i + 2;
		    v << char(hexvalue(s.(i - 1)) * 16 + hexvalue(s.i)))
	       else if '0' <= c && c < '8' then (
		    j := c - '0';
		    c = s.(i+1);
		    if '0' <= c && c < '8' then (
			 i = i+1;
			 j = 8 * j +  (c - '0');
			 c = s.(i+1);
			 if '0' <= c && c < '8' then (
			      i = i+1;
			      j = 8 * j +  (c - '0');
			      );
			 );
		    v << char(j)
		    )
	       else (
		    parseError = true;
		    parseMessage = "unknown escape sequence \\" + c;
		    v << c
		    )
	       )
	  else v << s.i;
	  i = i+1;
	  );
     tostring(v)
     );

export thenW := Word("-*dummy word: then*-",TCnone,hash_t(0),newParseinfo());		  -- filled in by binding.d
export whenW := Word("-*dummy word: when*-",TCnone,hash_t(0),newParseinfo());		  -- filled in by binding.d
export elseW := Word("-*dummy word: else*-",TCnone,hash_t(0),newParseinfo());		  -- filled in by binding.d
export ofW := Word("-*dummy word: of*-",TCnone,hash_t(0),newParseinfo());		  -- filled in by binding.d
export doW := Word("-*dummy word: do*-",TCnone,hash_t(0),newParseinfo());		  -- filled in by binding.d
export listW := Word("-*dummy word: list*-",TCnone,hash_t(0),newParseinfo());		  -- filled in by binding.d
export fromW := Word("-*dummy word: from*-",TCnone,hash_t(0),newParseinfo());		  -- filled in by binding.d
export inW := Word("-*dummy word: in*-",TCnone,hash_t(0),newParseinfo());		  -- filled in by binding.d
export toW := Word("-*dummy word: to*-",TCnone,hash_t(0),newParseinfo());		  -- filled in by binding.d
export debug := false;
export tracefile := dummyfile;
export openTokenFile(filename:string):(TokenFile or errmsg) := (
     when openPosIn(filename)
     is f:PosFile do (TokenFile or errmsg)(TokenFile(f,NULL))
     is s:errmsg  do (TokenFile or errmsg)(s)
     );
export setprompt(file:TokenFile,prompt:function():string):void := setprompt(file.posFile,prompt);
export unsetprompt(file:TokenFile):void := unsetprompt(file.posFile);
--Get next token in the file and advance to next token
export gettoken(file:TokenFile,obeylines:bool):Token := (
     when file.nexttoken
     is null do gettoken(file.posFile,obeylines)
     is w:Token do (
	  file.nexttoken = NULL;
     	  w
	  )
     );
--Peek at the next token in file without advancing in the file
export peektoken(file:TokenFile,obeylines:bool):Token := (
     when file.nexttoken
     is null do (
	  w := gettoken(file,obeylines);
	  file.nexttoken = w;
	  w
	  )
     is w:Token do w
     );
--What is this?   It doesn't appear to be used anywhere
level := 0;
--Empty Parsetree to represent error
export errorTree := ParseTree(dummy(dummyPosition));
skip(file:TokenFile,prec:int):void := (
     while peektoken(file,false).word.parse.precedence > prec 
     do gettoken(file,false)
     );
accumulate(e:ParseTree,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     if e == errorTree then return errorTree;
     ret := e;
     while true do (
	  token := peektoken(file,obeylines);
	  if token == errorToken then (
	       gettoken(file,obeylines);
	       ret = errorTree;
	       break;
	       );
	  if token.word.parse.precedence <= prec then break;
	  gettoken(file,obeylines);
	  ret = token.word.parse.funs.binary(ret,token,file,prec,obeylines);
	  if ret == errorTree then break;
	  );
     ret
     );
export errorunary(token1:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     printErrorMessage(token1,"syntax error at '" + token1.word.name + "'");
     errorTree
     );
export errorbinary(lhs:ParseTree, token2:Token, file:TokenFile, prec:int,obeylines:bool):ParseTree := (
     printErrorMessage(token2,"syntax error at '" + token2.word.name + "'");
     errorTree
     );
export defaultunary(token1:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     accumulate(ParseTree(token1),file,prec,obeylines)
     );
export precSpace := 0;		-- filled in later by binding.d
parse(file:TokenFile,prec:int,obeylines:bool):ParseTree;
nparse(file:TokenFile,prec:int,obeylines:bool):ParseTree;
export unaryop(token1:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     ret := parse(file,max(prec,token1.word.parse.unaryStrength),obeylines);
     if ret == errorTree then ret
     else accumulate(ParseTree(Unary(token1,ret)),file,prec,obeylines));
export nunaryop(token1:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     ret := nparse(file,token1.word.parse.unaryStrength,obeylines);
     if ret == errorTree then ret
     else accumulate(ParseTree(Unary(token1,ret)),file,prec,obeylines));
export nnunaryop(token1:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     if token1.word.parse.precedence <= prec
     then errorunary(token1,file,prec,obeylines)
     else (
	  ret := nparse(file,token1.word.parse.unaryStrength,obeylines);
	  if ret == errorTree then ret
	  else accumulate(ParseTree(Unary(token1,ret)),file,prec,obeylines)));
export defaultbinary(lhs:ParseTree, token2:Token, file:TokenFile, prec:int, obeylines:bool):ParseTree := (
     if token2.followsNewline then (
     	  printErrorMessage(token2,"missing semicolon or comma on previous line?");
     	  errorTree)
     else (
     	  ret := token2.word.parse.funs.unary(token2,file,precSpace-1,obeylines);
     	  if ret == errorTree then ret else ParseTree(Adjacent(lhs,ret))));
export postfixop(lhs:ParseTree, token2:Token, file:TokenFile, prec:int, obeylines:bool):ParseTree := (
     accumulate(ParseTree(Postfix(lhs,token2)),file,prec,obeylines));
export parse(file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     if prec == nopr then return errorTree;		    -- shouldn't ever happen
     token := gettoken(file,false);
     if token == errorToken then return errorTree;
     ret := token.word.parse.funs.unary(token,file,prec,obeylines);
     if ret == errorTree then (
	  if isatty(file) || file.posFile.file.fulllines then flushToken(file) else skip(file,prec));
     ret
     );
export nparse(file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     if prec == nopr then return errorTree;		    -- shouldn't ever happen
     token := peektoken(file,obeylines);
     if token == errorToken then return errorTree;
     ret := (
	  if token == errorToken
	  then errorTree
	  else if token.word.parse.precedence > prec
     	  then (
     	       token = gettoken(file,obeylines);
	       token.word.parse.funs.unary(token,file,prec,obeylines)
	       )
     	  else ParseTree(dummy(token.position))
	  );
     if ret == errorTree then (
	  if isatty(file) then flushToken(file) else skip(file,prec));
     ret
     );
export binaryop(lhs:ParseTree, token2:Token, file:TokenFile, prec:int, obeylines:bool):ParseTree := (
     ret := parse(file,token2.word.parse.binaryStrength,obeylines);
     if ret == errorTree then ret 
     else ParseTree(Binary(lhs, token2, ret)));
export nbinaryop(lhs:ParseTree, token2:Token, file:TokenFile, prec:int, obeylines:bool):ParseTree := (
     ret := nparse(file,token2.word.parse.binaryStrength,obeylines);
     if ret == errorTree then ret else ParseTree(Binary(lhs, token2, ret)));
export arrowop(lhs:ParseTree, token2:Token, file:TokenFile, prec:int, obeylines:bool):ParseTree := (
     e := parse(file,token2.word.parse.binaryStrength,obeylines);
     if e == errorTree then e else ParseTree(Arrow(lhs, token2, e, dummyDesc)));
MatchPair := {left:string, right:string, next:(null or MatchPair)};

matchList := (null or MatchPair)(NULL);
export addmatch(left:string, right:string):void := (
     matchList = MatchPair(left,right,matchList);
     );
matcher(left:string):string := (
     rest := matchList;
     while true do
     when rest is null do break	    	 	-- should not happen
     is matchPair:MatchPair do (
	  if matchPair.left == left then return matchPair.right;
	  rest = matchPair.next;	  
	  );
     ""
     );
export unaryparen(left:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     rightparen := matcher(left.word.name);
     if rightparen == peektoken(file,false).word.name
     then accumulate(ParseTree(EmptyParentheses(left,gettoken(file,false))),file,prec,obeylines)
     else (
	  e := parse(file,left.word.parse.unaryStrength,false);
	  if e == errorTree then return e;
	  right := gettoken(file,false);
	  if rightparen == right.word.name
	  then accumulate(ParseTree(Parentheses(left,e,right)),file,prec,obeylines)
	  else (
	       printErrorMessage(right, "expected \"" + rightparen + "\"");
	       printErrorMessage(left," ... to match this");
	       errorTree)));
export unarywhile(whileToken:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     predicate := parse(file,whileToken.word.parse.unaryStrength,false);
     if predicate == errorTree then return errorTree;
     token2 := gettoken(file,false);
     if token2 == errorToken then return errorTree;
     if token2.word == doW then (
	  doClause := parse(file,doW.parse.unaryStrength,obeylines);
	  if doClause == errorTree then return errorTree;
	  r := ParseTree(WhileDo(whileToken,predicate,token2,doClause));
	  accumulate(r,file,prec,obeylines))
     else if token2.word == listW then (
	  listClause := parse(file,listW.parse.unaryStrength,obeylines);
	  if listClause == errorTree then return errorTree;
	  if peektoken(file,obeylines).word == doW then (
	       doToken := gettoken(file,obeylines);
	       if doToken == errorToken then return errorTree;
	       doClause := parse(file,doW.parse.unaryStrength,obeylines);
	       if doClause == errorTree then return errorTree;
	       ret := ParseTree(WhileListDo(whileToken,predicate,token2,listClause,doToken,doClause));
	       accumulate(ret,file,prec,obeylines))
	  else (
	       ret := ParseTree(WhileList(whileToken,predicate,token2,listClause));
	       accumulate(ret,file,prec,obeylines)))
     else (
	  printErrorMessage(token2,"syntax error : expected 'do' or 'list'");
	  printErrorMessage(whileToken," ... to match this 'while'");
	  errorTree));

--Handle parsing a file following a for token
export unaryfor(forToken:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     var := parse(file,forToken.word.parse.unaryStrength,false);
     if var == errorTree then return errorTree;
     inClause := dummyTree;
     fromClause := dummyTree;
     toClause := dummyTree;
     whenClause := dummyTree;
     listClause := dummyTree;
     doClause := dummyTree;
     --get the next token
     token2 := gettoken(file,false);
     --if there is an error, return
     if token2 == errorToken then return errorTree;
     --if it is an "in" token
     if token2.word == inW then (
          --parse the part following the in token to become the in clause
	  inClause = parse(file,inW.parse.unaryStrength,false);
	  --on error return
	  if inClause == errorTree then return errorTree;
	  --otherwise get the next token
	  token2 = gettoken(file,false);
	  )
     else (
          --otherwise check to see if we have a from/to case
	  if token2.word == fromW then (
	       fromClause = parse(file,fromW.parse.unaryStrength,false);
	       if fromClause == errorTree then return errorTree;
	       token2 = gettoken(file,false);
	       );
	  if token2.word == toW then (
	       toClause = parse(file,toW.parse.unaryStrength,false);
	       if toClause == errorTree then return errorTree;
	       token2 = gettoken(file,false);
	       );
	  );
     --handle when clause
     if token2.word == whenW then (
	  whenClause = parse(file,whenW.parse.unaryStrength,false);
	  if whenClause == errorTree then return errorTree;
     	  token2 = gettoken(file,false);
	  );
     --this part should be followed by either a do clause or a list and then a do clause
     if token2.word == doW then (
	  doClause = parse(file,doW.parse.unaryStrength,obeylines);
	  if doClause == errorTree then return errorTree;
	  r := ParseTree(For( forToken, var, inClause, fromClause, toClause, whenClause, listClause,doClause, dummyDictionary ));
	  accumulate(r,file,prec,obeylines))
     else if token2.word == listW then (
	  listClause = parse(file,listW.parse.unaryStrength,obeylines);
	  if listClause == errorTree then return errorTree;
	  if peektoken(file,obeylines).word == doW then (
	       gettoken(file,obeylines);
	       doClause = parse(file,doW.parse.unaryStrength,obeylines);
	       if doClause == errorTree then return errorTree;
	       );
	  r := ParseTree(For(forToken, var, inClause, fromClause, toClause,whenClause, listClause, doClause, dummyDictionary));
	  accumulate(r,file,prec,obeylines))
     --if there is no do clause then it is an error
     else (
	  printErrorMessage(token2,"syntax error : expected 'do' or 'list'");
	  printErrorMessage(forToken," ... to match this 'for'");
	  errorTree));

-- unstringToken(q:Token):Token := (
--      if q.word.typecode == TCstring 
--      then (
-- 	  p := parseString(q.word.name);
-- 	  if parseError then (
-- 	       printErrorMessage(q,parseMessage);
-- 	       errorToken)
-- 	  else Token(
-- 	       makeUniqueWord(p,q.word.parse),
-- 	       q.filename, q.line, q.column, q.loadDepth,	    -- q.position,
-- 	       q.dictionary,q.entry,q.followsNewline)
-- 	  )
--      else q);

export unarysymbol(quotetoken:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     arg := gettoken(file,false);
     if arg == errorToken then return errorTree;
     if arg.word.typecode != TCid then ( printErrorMessage(arg, "syntax error: " + arg.word.name); return errorTree; );
     r := ParseTree(Quote(quotetoken,arg));
     accumulate(r,file,prec,obeylines));
export unaryglobal(quotetoken:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     arg := gettoken(file,false);
     if arg == errorToken then return errorTree;
     if arg.word.typecode != TCid then ( printErrorMessage(arg, "syntax error: " + arg.word.name); return errorTree; );
     r := ParseTree(GlobalQuote(quotetoken,arg));
     accumulate(r,file,prec,obeylines));
export unarythread(quotetoken:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     arg := gettoken(file,false);
     if arg == errorToken then return errorTree;
     if arg.word.typecode != TCid then ( printErrorMessage(arg, "syntax error: " + arg.word.name); return errorTree; );
     r := ParseTree(ThreadQuote(quotetoken,arg));
     accumulate(r,file,prec,obeylines));
export unarylocal(quotetoken:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     arg := gettoken(file,false);
     if arg == errorToken then return errorTree;
     if arg.word.typecode != TCid then ( printErrorMessage(arg, "syntax error: " + arg.word.name); return errorTree; );
     r := ParseTree(LocalQuote(quotetoken,arg));
     accumulate(r,file,prec,obeylines));
export unaryif(ifToken:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     predicate := parse(file,ifToken.word.parse.unaryStrength,false);
     if predicate == errorTree then return predicate;
     thenToken := gettoken(file,false);
     if thenToken == errorToken then return errorTree;
     if thenToken.word != thenW then (
	  printErrorMessage(thenToken,"syntax error : expected 'then'");
	  printErrorMessage(ifToken," ... to match this 'if'");
	  return errorTree);
     thenClause := parse(file,thenW.parse.unaryStrength,obeylines);
     if thenClause == errorTree then return errorTree;
     if peektoken(file,obeylines).word == elseW then (
     	  elseToken := gettoken(file,obeylines);
	  if elseToken == errorToken then return errorTree;
	  elseClause := parse(file,elseW.parse.unaryStrength,obeylines);
     	  if elseClause == errorTree then return errorTree;
	  ret := ParseTree(IfThenElse(ifToken,predicate,thenClause,elseClause));
	  accumulate(ret,file,prec,obeylines))
     else (
	  ret := ParseTree(IfThen(ifToken,predicate,thenClause));
	  accumulate(ret,file,prec,obeylines))
     );
export unarytry(tryToken:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     primary := parse(file,tryToken.word.parse.unaryStrength,obeylines);
     if primary == errorTree then return primary;
     if peektoken(file,obeylines).word == elseW then (
	  elseToken := gettoken(file,false);
	  if elseToken == errorToken then return errorTree;
	  if elseToken.word != elseW then (
	       printErrorMessage(elseToken,"syntax error : expected 'else'");
	       printErrorMessage(tryToken," ... to match this 'try'");
	       return errorTree);
	  elseClause := parse(file,elseW.parse.unaryStrength,obeylines);
	  if elseClause == errorTree then return errorTree;
	  accumulate(ParseTree(TryElse(tryToken,primary,elseToken,elseClause)),file,prec,obeylines))
     else if peektoken(file,obeylines).word == thenW then (
	  thenToken := gettoken(file,false);
	  if thenToken == errorToken then return errorTree;
	  thenClause := parse(file,thenW.parse.unaryStrength,obeylines);
	  if thenClause == errorTree then return errorTree;
	  if peektoken(file,obeylines).word == elseW then (
	       elseToken := gettoken(file,false);
	       if elseToken == errorToken then return errorTree;
	       elseClause := parse(file,elseW.parse.unaryStrength,obeylines);
	       if elseClause == errorTree then return errorTree;
	       accumulate(ParseTree(TryThenElse(tryToken,primary,thenToken,thenClause,elseToken,elseClause)),file,prec,obeylines))
	  else accumulate(ParseTree(TryThen(tryToken,primary,thenToken,thenClause)),file,prec,obeylines))
     else accumulate(ParseTree(Try(tryToken,primary)),file,prec,obeylines));
export unarycatch(catchToken:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     primary := parse(file,catchToken.word.parse.unaryStrength,obeylines);
     if primary == errorTree then return primary;
     accumulate(ParseTree(Catch(catchToken,primary)),file,prec,obeylines));
export unarynew(newtoken:Token,file:TokenFile,prec:int,obeylines:bool):ParseTree := (
     newclass := parse(file,newtoken.word.parse.unaryStrength,obeylines);
     if newclass == errorTree then return errorTree;
     ofToken := dummyToken;
     newparent := dummyTree;
     if peektoken(file,obeylines).word == ofW then (
	  ofToken = gettoken(file,obeylines);
	  newparent = parse(file,ofW.parse.unaryStrength,obeylines);
	  if newparent == errorTree then return errorTree;
	  );
     fromToken := dummyToken;
     newinitializer := dummyTree;
     if peektoken(file,obeylines).word == fromW then (
	  fromToken = gettoken(file,obeylines);
	  newinitializer = parse(file,fromW.parse.unaryStrength,obeylines);
	  if newinitializer == errorTree then return errorTree;
	  );
     accumulate(ParseTree(New(newtoken,newclass,newparent,newinitializer)),file,prec,obeylines));

export treePosition(e:ParseTree):Position := (
    when e
    is t:Token            do t.position
    is s:Parentheses      do combinePositionL(s.left.position,       s.right.position)
    is s:EmptyParentheses do combinePositionL(s.left.position,       s.right.position)
    is a:Adjacent         do combinePositionM(treePosition(a.lhs),   treePosition(a.rhs))
    is a:Arrow            do combinePositionL(treePosition(a.lhs),   treePosition(a.rhs))
    is o:Unary            do combinePositionL(o.Operator.position,   treePosition(o.rhs))
    is o:Binary           do combinePositionC(treePosition(o.lhs),   treePosition(o.rhs), o.Operator.position)
    is o:Postfix          do combinePositionR(treePosition(o.lhs),   o.Operator.position)
    is o:Quote            do combinePositionL(o.Operator.position,   o.rhs.position)
    is o:GlobalQuote      do combinePositionL(o.Operator.position,   o.rhs.position)
    is o:ThreadQuote      do combinePositionL(o.Operator.position,   o.rhs.position)
    is o:LocalQuote       do combinePositionL(o.Operator.position,   o.rhs.position)
    is t:IfThen           do combinePositionL(t.ifToken.position,    treePosition(t.thenClause))
    is t:IfThenElse       do combinePositionL(t.ifToken.position,    treePosition(t.elseClause))
    is t:Try              do combinePositionL(t.tryToken.position,   treePosition(t.primary))
    is t:TryThen          do combinePositionL(t.tryToken.position,   treePosition(t.sequel))
    is t:TryThenElse      do combinePositionL(t.tryToken.position,   treePosition(t.alternate))
    is t:TryElse          do combinePositionL(t.tryToken.position,   treePosition(t.alternate))
    is t:Catch            do combinePositionL(t.catchToken.position, treePosition(t.primary))
    is t:WhileDo          do combinePositionL(t.whileToken.position, treePosition(t.doClause))
    is t:WhileListDo      do combinePositionL(t.whileToken.position, treePosition(t.doClause))
    is t:WhileList        do combinePositionL(t.whileToken.position, treePosition(t.listClause))
    -- TODO: split into ForDo and ForList
    is t:For do (
	lastClause := if t.doClause != dummyTree then t.doClause else t.listClause;
	combinePositionL(t.forToken.position, treePosition(lastClause)))
    -- TODO: split into New, NewOf, NewFrom, and NewOfFrom
    is t:New do (
	lastClass :=
	if t.newInitializer != dummyTree then t.newInitializer else
	if t.newParent      != dummyTree then t.newParent      else t.newClass;
	combinePositionL(t.newToken.position, treePosition(lastClass)))
    is dummy do dummyPosition
    );

size(x:Token):int := Ccode(int,"sizeof(*",x,")");
size(x:functionDescription):int := Ccode(int,"sizeof(*",x,")");
export size(e:ParseTree):int := (
     Ccode(int,"sizeof(",e,")") +
     when e
     is x:dummy do Ccode(int,"sizeof(*",x,")") + Ccode(int,"sizeof(*",x.position,")")
     is x:Token do size(x)
     is x:Adjacent do Ccode(int,"sizeof(*",x,")") + size(x.lhs) + size(x.rhs)
     is x:Binary do Ccode(int,"sizeof(*",x,")") + size(x.lhs) + size(x.rhs) + size(x.Operator)
     is x:Arrow do Ccode(int,"sizeof(*",x,")") + size(x.lhs) + size(x.rhs) + size(x.Operator) + size(x.desc)
     is x:Unary do Ccode(int,"sizeof(*",x,")") + size(x.rhs) + size(x.Operator)
     is x:Postfix do Ccode(int,"sizeof(*",x,")") + size(x.lhs) + size(x.Operator)
     is x:Quote do Ccode(int,"sizeof(*",x,")") + size(x.rhs) + size(x.Operator)
     is x:GlobalQuote do Ccode(int,"sizeof(*",x,")") + size(x.rhs) + size(x.Operator)
     is x:ThreadQuote do Ccode(int,"sizeof(*",x,")") + size(x.rhs) + size(x.Operator)
     is x:LocalQuote do Ccode(int,"sizeof(*",x,")") + size(x.rhs) + size(x.Operator)
     is x:Parentheses do Ccode(int,"sizeof(*",x,")") + size(x.left) + size(x.right) + size(x.contents)
     is x:EmptyParentheses do Ccode(int,"sizeof(*",x,")") + size(x.left) + size(x.right)
     is x:IfThen do Ccode(int,"sizeof(*",x,")") + size(x.ifToken) + size(x.predicate) + size(x.thenClause)
     is x:IfThenElse do Ccode(int,"sizeof(*",x,")") + size(x.ifToken) + size(x.predicate) + size(x.thenClause) + size(x.elseClause)
    is x:TryThenElse do Ccode(int,"sizeof(*",x,")") + size(x.tryToken) + size(x.primary) + size(x.thenToken) + size(x.sequel) + size(x.elseToken) + size(x.alternate)
    is x:TryThen     do Ccode(int,"sizeof(*",x,")") + size(x.tryToken) + size(x.primary) + size(x.thenToken) + size(x.sequel)
    is x:TryElse     do Ccode(int,"sizeof(*",x,")") + size(x.tryToken) + size(x.primary)                                      + size(x.elseToken) + size(x.alternate)
    is x:Try         do Ccode(int,"sizeof(*",x,")") + size(x.tryToken) + size(x.primary)
     is x:Catch do Ccode(int,"sizeof(*",x,")") + size(x.catchToken) + size(x.primary)
     is x:For do Ccode(int,"sizeof(*",x,")")+ size(x.forToken) + size(x.variable) + size(x.inClause) + size(x.fromClause) + size(x.toClause) + size(x.whenClause) + size(x.listClause) + size(x.doClause)
     is x:WhileDo do Ccode(int,"sizeof(*",x,")") + size(x.whileToken) + size(x.predicate) + size(x.dotoken) + size(x.doClause)
     is x:WhileList do Ccode(int,"sizeof(*",x,")") + size(x.whileToken) + size(x.predicate) + size(x.listtoken) + size(x.listClause)
     is x:WhileListDo do Ccode(int,"sizeof(*",x,")") + size(x.whileToken) + size(x.predicate) + size(x.dotoken) + size(x.doClause) + size(x.listtoken) + size(x.listClause)
    is x:New do Ccode(int,"sizeof(*",x,")") + size(x.newToken) + size(x.newClass) + size(x.newParent) + size(x.newInitializer)
     );

-- Local Variables:
-- compile-command: "echo \"make: Entering directory \\`$M2BUILDDIR/Macaulay2/d'\" && make -C $M2BUILDDIR/Macaulay2/d "
-- End:
