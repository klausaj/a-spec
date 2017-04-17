syn match Keyword "<DocumentInfo>"
syn match Keyword "</DocumentInfo>"
syn match Keyword "<Directive>"
syn match Keyword "</Directive>"
syn match Keyword "<Description>"
syn match Keyword "</Description>"

syn match Keyword "[ \r\n\t]basic[ \r\n\t]"
syn match Keyword "[ \r\n\t]schema[ \r\n\t]"
syn match Keyword "[ \r\n\t]free[ \r\n\t]"
syn match Keyword "[ \r\n\t]type[ \r\n\t]"
syn match Keyword "[ \r\n\t]axdef[ \r\n\t]"
syn match Keyword "[ \r\n\t]gendef[\[ \r\n\t]"me=e-1
syn match Keyword "[ \r\n\t]gensch[\[ \r\n\t]"me=e-1
syn match Keyword "[ \r\n\t]const[ \r\n\t]"
syn match Keyword "[ \r\n\t]process[ \r\n\t]"
syn match Keyword "\.\."

syn keyword Keyword pset seq int begin string char true false
syn keyword Keyword zpre zpost zunp ztype zproj zcomp zhide zpipe zin zout xi
syn keyword Keyword pseq phide zover pren
syn keyword Keyword CSP_EVENT PROCESS

syn keyword Structure chan proc

syn keyword apre docID docVer docRev aSpecVer iseq seq1 in sub seqin prefix suffix
syn keyword apre over uni diff cat div mod seqext seqfilt inter choose set1 dres
syn keyword apre fset fset1 size first second subeq !in nat dom ran nat1 rev inv
syn keyword apre guni ginter head tail front last min max pset1 seqidx split join
syn keyword apre BYTE_ARRAY BOOL GEN_DATA UINT64 UINT32 UINT16 UINT8 INT64 INT32
syn keyword apre SKIP CHAOS STOP DIVER CSP_REF refID REFERENCE REFERENCE_ASSIGN
syn keyword apre RUN RUN_CHECK ENV ENVx check EVENT EVENT_CHECK alph alphcheck tau
syn keyword apre insert ENVa abs
syn keyword apre INVALID_REF disjoint partitions dcat rcomp rres ndres nrres squash
syn keyword apre rrcomp id rimg assert LAYER_ID trim TRUE FALSE A2TEX_XFM INT16
syn keyword apre INT8 display derive int2Gen gen2Int CHAN eseq eset

syn match Operator "|"
syn match Operator "|-->"
syn match Operator "<-->"
syn match Operator "--|>"
syn match Operator "--->"
syn match Operator ">-|>"
syn match Operator ">-->"
syn match Operator "-|>>"
syn match Operator "-->>"
syn match Operator ">->>"
syn match Operator "-||>"
syn match Operator ">||>"
syn match Operator "&&"
syn match Operator "||"
syn match Operator "&"
syn match Operator "<=>"
syn match Operator "==>"
syn match Operator "->"
syn match Operator "\[\]"
syn match Operator "|\~|"
syn match Operator "|||"
syn match Operator "/\\"
syn match Operator "\[|"
syn match Operator "|\]"
syn match Comment "@\\"
syn match Comment "@\\1"
syn match Comment "@\\\*"
syn keyword Structure func bool oper rel pre1 pre2 pre3 pre4 pre5 pre6 pre7 pre8 pre9 post1 post2 post3
syn keyword Structure post4 post5 post6 post7 post8 post9 bin1 bin2 bin3 bin4 bin5 bin6 bin7 bin8 bin9
syn keyword Repeat forAll exists exists1 tuple setDisp seqDisp cross setComp
syn keyword Repeat lambda mu schType schBind let
syn match asyn "\[delta[0-9]*\]"
syn match asyn "\['[0-9]*\]"
syn match asyn "\[?\]"
syn match asyn "\[!\]"
syn match Define "#import.*"
syn match Define "#fileID.*"

syn keyword Conditional if then else elif endif containedin=ifReg
syn keyword ifExclude end containedin=ifReg
syn keyword ifErr then else elif endif

syn keyword ifKey end
syn keyword Keyword where

syn region ifReg transparent start="[; \r\n\t\(\{]if[\{\( \r\n\t]" end="[; \r\n\t\)\}]endif[\)\};\r\n \t]" contains=ALLBUT,ifErr,TError,ifKey keepend extend

syn region Text matchgroup=Keyword start="<Text>"rs=e matchgroup=Keyword end="</Text>"re=s contains=TError,Error
syn region Define matchgroup=Keyword start="<Properties>"rs=e+1 matchgroup=Keyword end="</Properties>"re=s-1 contains=PError,PreProp
syn region Comment start="%" end="%"
syn region Comment start="@\[" end="\]"

syn keyword PreProp LAYER_ID A2TEX_XFM

syn region Define start="# *\[" end="\]"

syn match Error " \+$"
syn match Error "\t"

syn match PError " \+$"
syn match PError "\t"

syn match TError "/" contained containedin=Text
syn match TError "<" contained containedin=Text
syn match TError ">" contained containedin=Text

" console/terminal settings
hi ablocks ctermfg=green ctermbg=white guifg=green guibg=white
hi apre term=bold cterm=bold ctermfg=darkblue gui=bold guifg=darkblue guibg=white
hi asyn term=bold cterm=bold ctermfg=darkgreen gui=bold guifg=black guibg=white

hi link TError Error
hi link PError Error
hi link PreProp apre
hi link ifExclude Error
hi link ifErr Error
hi link ifKey Keyword
hi link Text Comment

set nospell
set hlsearch

let b:current_syntax = "aspec"
syntax sync minlines=360
