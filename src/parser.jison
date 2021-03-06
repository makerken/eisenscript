%lex
%%

\s+                       /* skip */
"//".*                    /* ignore comment */
"/*"[\w\W]*?"*/"          /* ignore comment */

"set"                     return 'SET'
"w"                       return 'WEIGHT';
"weight"                  return 'WEIGHT';
"md"                      return 'MAXDEPTH';
"maxdepth"                return 'MAXDEPTH';
"maxobjects"              return 'MAXOBJECTS';
"minsize"                 return 'MINSIZE';
"maxsize"                 return 'MAXSIZE';
"seed"                    return 'SEED';
"initial"                 return 'INITIAL';
"background"              return 'BACKGROUND';
"colorpool"               return 'COLORPOOL';
"rule"                    return 'RULE';
">"                       return '>';
"{"                       return '{';
"}"                       return '}';
"["                       return '[';
"]"                       return ']';
"^"                       return '^';
"*"                       return '*';
"/"                       return '/';
"+"                       return '+';
"-"                       return '-';
"("                       return '(';
")"                       return ')';
","                       return ',';
"x"                       return 'XSHIFT';
"y"                       return 'YSHIFT';
"z"                       return 'ZSHIFT';
"rx"                      return 'ROTATEX';
"ry"                      return 'ROTATEY';
"rz"                      return 'ROTATEZ';
"s"                       return 'SIZE';
"m"                       return 'MATRIX';
"matrix"                  return 'MATRIX';
"hue"                     return 'HUE';
"h"                       return 'HUE';
"saturation"              return 'SATURATION';
"sat"                     return 'SATURATION';
"brightness"              return 'BRIGHTNESS';
"b"                       return 'BRIGHTNESS';
"alpha"                   return 'ALPHA';
"a"                       return 'ALPHA';
"color"                   return 'COLOR';
"random"                  return 'RANDOM';
"blend"                   return 'BLEND';
"randomhue"               return 'RANDOMHUE';
"randomrgb"               return 'RANDOMRGB';
"greyscale"               return 'GREYSCALE';
<<EOF>>                   return 'EOF';
[0-9]+("."[0-9]*)?        return 'NUMBER';
"."[0-9]+                 return 'NUMBER';
"list:"[\w,]+             return 'COLORLIST';
"image:"[\w\.\w]+         return 'IMAGE';
[a-zA-Z_]+[a-zA-Z0-9_]*   return 'STRING';
"#define"                 return 'DEFINE';
"#"[a-fA-F0-9]{6}         return 'COLOR6';
"#"[a-fA-F0-9]{3}         return 'COLOR3';


/lex

%left '+' '-'
%left '*' '/'
%left '^'
%left NEG POS


////////////////////////////////////////////////////
//  EISENSCRIPT
////////////////////////////////////////////////////

%start eisenscript

%% /* language grammar */

eisenscript
  : lines EOF { $$ = $1; return $$; }
  ;

lines
  : lines line { $$ = $1; $$.push($2); }
  | { $$ = []; }
  ;

line
  : maxdepth   { $$ = $1; }
  | maxobjects { $$ = $1; }
  | minsize    { $$ = $1; }
  | maxsize    { $$ = $1; }
  | seed       { $$ = $1; }
  | background { $$ = $1; }
  | color      { $$ = $1; }
  | colorpool  { $$ = $1; }
  | define     { $$ = $1; }
  | rule       { $$ = $1; }
  | statement  { $$ = $1; $1.computed = true; }
  ;


////////////////////////////////////////////////////
//  ACTION
////////////////////////////////////////////////////

maxdepth
  : SET MAXDEPTH num { $$ = { type: 'set', key: 'maxdepth', value: $3 }; }
  ;

maxobjects
  : SET MAXOBJECTS num { $$ = { type: 'set', key: 'maxobjects', value: $3 }; }
  ;

minsize
  : SET MINSIZE num { $$ = { type: 'set', key: 'minsize', value: $3 }; }
  ;

maxsize
  : SET MAXSIZE num { $$ = { type: 'set', key: 'maxsize', value: $3 }; }
  ;

seed
  : SET SEED num     { $$ = { type: 'set', key: 'seed', value: $3 }; }
  | SET SEED INITIAL { $$ = { type: 'set', key: 'seed', value: $3 }; }
  ;

background
  : SET BACKGROUND COLOR3 { $$ = { type: 'set', key: 'background', value: $3.toLowerCase() }; }
  | SET BACKGROUND COLOR6 { $$ = { type: 'set', key: 'background', value: $3.toLowerCase() }; }
  | SET BACKGROUND STRING { $$ = { type: 'set', key: 'background', value: $3.toLowerCase() }; }
  | SET BACKGROUND RANDOM { $$ = { type: 'set', key: 'background', value: $3.toLowerCase() }; }
  ;

color
  : SET COLOR RANDOM { $$ = { type: 'set', key: 'color', value: $3.toLowerCase() }; }
  ;

colorpool
  : SET COLORPOOL RANDOMHUE { $$ = { type: 'set', key: 'colorpool', value: $3.toLowerCase() }; }
  | SET COLORPOOL RANDOMRGB { $$ = { type: 'set', key: 'colorpool', value: $3.toLowerCase() }; }
  | SET COLORPOOL GREYSCALE { $$ = { type: 'set', key: 'colorpool', value: $3.toLowerCase() }; }
  | SET COLORPOOL COLORLIST { $$ = { type: 'set', key: 'colorpool', value: $3.toLowerCase() }; }
  | SET COLORPOOL IMAGE     { $$ = { type: 'set', key: 'colorpool', value: $3.toLowerCase() }; }
  ;

define
  : DEFINE STRING num { $$ = { type: 'define', varname: $2, value: $3 }; }
  ;

////////////////////////////////////////////////////
//  RULE
////////////////////////////////////////////////////

rule
  : RULE id modifiers '{' statements '}'  { $$ = { type: 'rule', id: $2, params: $3, body: $5 }; }
  ;

modifiers
  : modifiers modifier { $$ = $1; $$.push($2); }
  | { $$ = []; }
  ;

modifier
  : WEIGHT num                 { $$ = { type: 'modifier', key: 'weight',   value: $2 }; }
  | MAXDEPTH num               { $$ = { type: 'modifier', key: 'maxdepth', value: $2 }; }
  | MAXDEPTH num '>' rulename  { $$ = { type: 'modifier', key: 'maxdepth', value: $2, alternate: $4}; }
  ;

statements
  : statements statement { $$ = $1; $$.push($2); }
  | { $$ = []; }
  ;

statement
  : expressions id { $$ = { type: 'statement', id: $2, exprs: $1 }; }
  ;

expressions
  : expressions expression { $$ = $1; $$.push($2); }
  | { $$ = []; }
  ;

expression
  : object       { $$ = { type: 'expr', left:  1, right: $1 }; }
  | n '*' object { $$ = { type: 'expr', left: $1, right: $3 }; }
  ;

object
  : '{' properties '}' { $$ = { type: 'object', properties: $2 }; }
  ;

properties
  : properties property { type: 'property', $$ = $1; $$.push($2); }
  | { $$ = []; }
  ;

property
  : geo
  | color
  ;


////////////////////////////////////////////////////
//  ATTRIBUTE
////////////////////////////////////////////////////

geo
  : XSHIFT num       { $$ = { type: 'property', key: 'xshift',  value: $2 }; }
  | YSHIFT num       { $$ = { type: 'property', key: 'yshift',  value: $2 }; }
  | ZSHIFT num       { $$ = { type: 'property', key: 'zshift',  value: $2 }; }
  | ROTATEX num      { $$ = { type: 'property', key: 'rotatex', value: $2 }; }
  | ROTATEY num      { $$ = { type: 'property', key: 'rotatey', value: $2 }; }
  | ROTATEZ num      { $$ = { type: 'property', key: 'rotatez', value: $2 }; }
  | SIZE num         { $$ = { type: 'property', key: 'size',    value: { x: $2, y: $2, z: $2 } }; }
  | SIZE num num num { $$ = { type: 'property', key: 'size',    value: { x: $2, y: $3, z: $4 } }; }
  | MATRIX num num num num num num num num num { $$ = { type: 'property', key: 'matrix', value: [$2, $3, $4, $5, $6, $7, $8, $9, $10] }; }
  ;

color
  : HUE num          { $$ = { type: 'property', key: 'hue',   value: $2 }; }
  | ALPHA num        { $$ = { type: 'property', key: 'alpha', value: $2 }; }
  | COLOR COLOR3     { $$ = { type: 'property', key: 'color', value: $2.toLowerCase() }; }
  | COLOR COLOR6     { $$ = { type: 'property', key: 'color', value: $2.toLowerCase() }; }
  | COLOR RANDOM     { $$ = { type: 'property', key: 'color', value: $2.toLowerCase() }; }
  | COLOR STRING     { $$ = { type: 'property', key: 'color', value: $2.toLowerCase() }; }
  | BLEND COLOR3 num { $$ = { type: 'property', key: 'blend', color: $2.toLowerCase(), strength: $3 }; }
  | BLEND COLOR6 num { $$ = { type: 'property', key: 'blend', color: $2.toLowerCase(), strength: $3 }; }
  | BLEND RANDOM num { $$ = { type: 'property', key: 'blend', color: $2.toLowerCase(), strength: $3 }; }
  | BLEND STRING num { $$ = { type: 'property', key: 'blend', color: $2.toLowerCase(), strength: $3 }; }
  | SATURATION num   { $$ = { type: 'property', key: 'saturation', value: $2 }; }
  | BRIGHTNESS num   { $$ = { type: 'property', key: 'brightness', value: $2 }; }
  ;


////////////////////////////////////////////////////
//  LITERAL
////////////////////////////////////////////////////

num
  : n
  | '+' n         { $$ =  $2; }
  | '-' n         { $$ = -$2; }
  | n '*' n       { $$ =  $1*$3; }
  | n '/' n       { $$ =  $1/$3; }
  | '-' n '*' n   { $$ = -$2*$4; }
  | '-' n '/' n   { $$ = -$2/$4; }
  | '(' e ')'     { $$ =  $2; }
  ;

n
  : NUMBER { $$ = parseFloat(yytext); }
  ;

id
  : STRING { $$ = yytext; }
  ;

rulename
  : STRING {$$ = $1; }
  ;
