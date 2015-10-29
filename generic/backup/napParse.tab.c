/* A Bison parser, made from napParse.y
   by GNU bison 1.35.  */

#define YYBISON 1  /* Identify Bison output.  */

#define yyparse Nap_parse
#define yylex Nap_lex
#define yyerror Nap_error
#define yylval Nap_lval
#define yychar Nap_char
#define yydebug Nap_debug
#define yynerrs Nap_nerrs
# define	NULL_OP	257
# define	ID	258
# define	NAME	259
# define	STRING	260
# define	UNUMBER	261
# define	CAT	262
# define	LAMINATE	263
# define	CLOSEST	264
# define	MATCH	265
# define	TO	266
# define	AP3	267
# define	EQ	268
# define	NE	269
# define	LE	270
# define	GE	271
# define	SHIFT_LEFT	272
# define	LESSER_OF	273
# define	SHIFT_RIGHT	274
# define	GREATER_OF	275
# define	AND	276
# define	OR	277
# define	POWER	278
# define	INNER_PROD	279
# define	FUNCTION	280

#line 1 "napParse.y"


/*
 * napParse.y --
 *
 * Copyright (c) 1998, CSIRO Australia
 *
 * bison source code defining expression parser
 * bison is a gnu's yacc
 *
 * Author: Harvey Davies, CSIRO Mathematical and Information Sciences
 *
 */

#ifndef lint
static char *rcsid="@(#) $Id: napParse.y,v 1.67 2005/10/26 08:34:20 dav480 Exp $";
#endif /* not lint */

#ifdef WIN32
#include <malloc.h>
#endif /* WIN32 */

#include "nap.h"
#include "nap_check.h"

#define YYERROR_VERBOSE 1
#define YYSTYPE Nap_stype
#define YYPARSE_PARAM Nap_param
#define YYLEX_PARAM Nap_param

#ifndef YYDEBUG
# define YYDEBUG 0
#endif



#define	YYFINAL		142
#define	YYFLAG		-32768
#define	YYNTBASE	58

/* YYTRANSLATE(YYLEX) -- Bison token number corresponding to YYLEX. */
#define YYTRANSLATE(x) ((unsigned)(x) <= 280 ? yytranslate[x] : 70)

/* YYTRANSLATE[YYLEX] -- Bison token number corresponding to YYLEX. */
static const char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,    27,    28,    29,    30,    31,    32,    33,     2,
      34,    35,    36,    37,    38,    39,    40,    41,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    42,    43,
      44,    45,    46,    47,    48,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    49,     2,    50,    51,    52,    53,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    54,    55,    56,    57,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     3,     4,     5,
       6,     7,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26
};

#if YYDEBUG
static const short yyprhs[] =
{
       0,     0,     1,     3,     5,     7,     9,    11,    13,    17,
      21,    25,    29,    33,    37,    41,    45,    49,    53,    57,
      61,    65,    69,    73,    77,    81,    85,    89,    93,    97,
     101,   105,   109,   113,   117,   121,   125,   129,   133,   137,
     141,   145,   149,   152,   155,   158,   161,   164,   167,   170,
     173,   176,   179,   182,   185,   188,   191,   194,   197,   199,
     201,   205,   208,   211,   214,   217,   219,   221,   223,   227,
     229,   231,   233,   235,   239,   242,   244,   246,   248,   250,
     254,   255,   258,   260,   264,   266,   270,   272,   275,   278
};
static const short yyrhs[] =
{
      -1,    59,     0,    62,     0,    64,     0,    63,     0,    69,
       0,     5,     0,     5,    45,    59,     0,    59,    38,    59,
       0,    59,     8,    59,     0,    59,     9,    59,     0,    59,
      48,    59,     0,    59,    30,    59,     0,    59,    10,    59,
       0,    59,    11,    59,     0,    59,    47,    59,     0,    59,
      42,    59,     0,    59,    12,    59,     0,    59,    13,    59,
       0,    59,    23,    59,     0,    59,    22,    59,     0,    59,
      14,    59,     0,    59,    15,    59,     0,    59,    16,    59,
       0,    59,    19,    59,     0,    59,    21,    59,     0,    59,
      44,    59,     0,    59,    17,    59,     0,    59,    46,    59,
       0,    59,    37,    59,     0,    59,    39,    59,     0,    59,
      36,    59,     0,    59,    41,    59,     0,    59,    32,    59,
       0,    59,    25,    59,     0,    59,    24,    59,     0,    59,
      33,    59,     0,    59,    55,    59,     0,    59,    51,    59,
       0,    59,    18,    59,     0,    59,    20,    59,     0,    28,
      59,     0,    30,    59,     0,    39,    59,     0,    57,    59,
       0,    37,    59,     0,    51,    59,     0,    44,    59,     0,
      46,    59,     0,    55,    59,     0,    48,    59,     0,    10,
      59,     0,    11,    59,     0,    16,    59,     0,    17,    59,
       0,    38,    59,     0,    59,    38,     0,    38,     0,    39,
       0,    34,    59,    35,     0,     5,     5,     0,     5,    61,
       0,    60,     5,     0,    60,    61,     0,    64,     0,    63,
       0,    62,     0,    34,    59,    35,     0,    69,     0,    64,
       0,    63,     0,    62,     0,    34,    59,    35,     0,    34,
      35,     0,    69,     0,     4,     0,     6,     0,    65,     0,
      54,    66,    56,     0,     0,    66,    67,     0,    68,     0,
       7,    30,    68,     0,    65,     0,     7,    30,    65,     0,
      69,     0,    39,    69,     0,    37,    69,     0,     7,     0
};

#endif

#if YYDEBUG
/* YYRLINE[YYN] -- source line where rule number YYN was defined. */
static const short yyrline[] =
{
       0,   103,   104,   107,   108,   109,   110,   112,   113,   115,
     116,   117,   118,   119,   120,   121,   122,   123,   124,   125,
     126,   127,   128,   129,   130,   131,   132,   133,   134,   135,
     136,   137,   138,   139,   140,   141,   142,   143,   144,   145,
     146,   147,   148,   149,   150,   151,   152,   153,   154,   155,
     156,   157,   158,   159,   160,   161,   162,   163,   164,   165,
     166,   167,   170,   172,   174,   178,   179,   180,   181,   182,
     186,   187,   188,   189,   190,   191,   195,   198,   201,   204,
     208,   209,   212,   213,   214,   215,   218,   219,   220,   223
};
#endif


#if (YYDEBUG) || defined YYERROR_VERBOSE

/* YYTNAME[TOKEN_NUM] -- String name of the token TOKEN_NUM. */
static const char *const yytname[] =
{
  "$", "error", "$undefined.", "NULL_OP", "ID", "NAME", "STRING", "UNUMBER", 
  "CAT", "LAMINATE", "CLOSEST", "MATCH", "TO", "AP3", "EQ", "NE", "LE", 
  "GE", "SHIFT_LEFT", "LESSER_OF", "SHIFT_RIGHT", "GREATER_OF", "AND", 
  "OR", "POWER", "INNER_PROD", "FUNCTION", "' '", "'!'", "'\\\"'", "'#'", 
  "'$'", "'%'", "'&'", "'('", "')'", "'*'", "'+'", "','", "'-'", "'.'", 
  "'/'", "':'", "';'", "'<'", "'='", "'>'", "'?'", "'@'", "'['", "']'", 
  "'^'", "'_'", "'`'", "'{'", "'|'", "'}'", "'~'", "result", "expr", 
  "FuncArg1", "FuncArg2", "naoID", "stringConst", "arrayConst", "encList", 
  "list", "element", "ssnv", "usnv", 0
};
#endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives. */
static const short yyr1[] =
{
       0,    58,    58,    59,    59,    59,    59,    59,    59,    59,
      59,    59,    59,    59,    59,    59,    59,    59,    59,    59,
      59,    59,    59,    59,    59,    59,    59,    59,    59,    59,
      59,    59,    59,    59,    59,    59,    59,    59,    59,    59,
      59,    59,    59,    59,    59,    59,    59,    59,    59,    59,
      59,    59,    59,    59,    59,    59,    59,    59,    59,    59,
      59,    59,    59,    59,    59,    60,    60,    60,    60,    60,
      61,    61,    61,    61,    61,    61,    62,    63,    64,    65,
      66,    66,    67,    67,    67,    67,    68,    68,    68,    69
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN. */
static const short yyr2[] =
{
       0,     0,     1,     1,     1,     1,     1,     1,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     1,     1,
       3,     2,     2,     2,     2,     1,     1,     1,     3,     1,
       1,     1,     1,     3,     2,     1,     1,     1,     1,     3,
       0,     2,     1,     3,     1,     3,     1,     2,     2,     1
};

/* YYDEFACT[S] -- default rule to reduce with in state S when YYTABLE
   doesn't specify something else to do.  Zero means the default is an
   error. */
static const short yydefact[] =
{
       1,    76,     7,    77,    89,     0,     0,     0,     0,     0,
       0,     0,     0,    58,    59,     0,     0,     0,     0,    80,
       0,     0,     2,     0,     3,     5,     4,    78,     6,    61,
       0,     0,    62,    72,    71,    70,    75,    52,    53,    54,
      55,    42,    43,     0,    46,    56,    44,    48,    49,    51,
      47,     0,    50,    45,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    57,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    63,    64,    74,
       0,     8,    60,    89,     0,     0,    79,    84,    81,    82,
      86,    10,    11,    14,    15,    18,    19,    22,    23,    24,
      28,    40,    25,    41,    26,    21,    20,    36,    35,    13,
      34,    37,    32,    30,     9,    31,    33,    17,    27,    29,
      16,    12,    39,    38,    73,     0,    88,    87,    85,    83,
       0,     0,     0
};

static const short yydefgoto[] =
{
     140,    22,    23,    32,    24,    25,    26,    27,    51,    98,
      99,    28
};

static const short yypact[] =
{
     138,-32768,   146,-32768,-32768,   138,   138,   138,   138,   138,
     138,   138,   138,   192,   103,   138,   138,   138,   138,-32768,
     138,   138,   394,    92,   200,   207,   211,-32768,   246,-32768,
      84,   138,-32768,-32768,-32768,-32768,-32768,    -1,    -1,    -1,
      -1,    -1,    -1,   298,    -1,   442,    -1,    -1,    -1,    -1,
      -1,   223,    -1,    -1,   138,   138,   138,   138,   138,   138,
     138,   138,   138,   138,   138,   138,   138,   138,   138,   138,
     138,   138,   138,   138,   138,   138,   138,   192,   138,   138,
     138,   138,   138,   138,   138,   138,   138,-32768,-32768,-32768,
     346,   394,   251,    -8,    19,    19,-32768,-32768,-32768,-32768,
  -32768,   488,   488,    -1,    -1,   531,   573,   816,   816,   848,
     848,   912,   880,   912,   880,   657,   615,    -1,   945,   177,
     883,   777,   883,   922,   442,   922,   883,   488,   848,   848,
     488,    -1,   738,   699,-32768,   230,-32768,-32768,-32768,-32768,
      24,    25,-32768
};

static const short yypgoto[] =
{
  -32768,    -3,-32768,     6,    14,    17,    18,   -50,-32768,-32768,
    -105,    -2
};


#define	YYLAST		993


static const short yytable[] =
{
      36,    97,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    33,    52,    53,    34,
      35,    36,   135,    70,   141,   142,     4,    90,    91,    88,
     139,     0,     0,     0,     0,     0,     0,    33,     0,     0,
      34,    35,     0,     0,     0,     0,     0,     0,     0,   100,
       0,   101,   102,   103,   104,   105,   106,   107,   108,   109,
     110,   111,   112,   113,   114,   115,   116,   117,   118,   119,
     120,   121,   122,   123,   124,   125,   126,   127,   128,   129,
     130,   131,   132,   133,     0,   138,     0,     0,     1,     2,
       3,     4,   136,   137,     5,     6,     1,    87,     3,     4,
       7,     8,     0,     0,     0,     0,     0,     1,     2,     3,
       4,     0,     9,     0,    10,     0,     0,     0,    11,    89,
       0,    12,    13,    14,     0,     0,    30,     0,    15,     0,
      16,     9,    17,   100,     0,    18,     0,    11,    19,    20,
       0,    21,     1,     2,     3,     4,    19,     0,     5,     6,
       1,    29,     3,     4,     7,     8,     0,    19,     0,     0,
      21,     0,     0,     0,     0,     0,     9,     0,    10,     0,
       0,     0,    11,     0,     0,    12,    13,    14,     0,     0,
      30,     0,    15,     0,    16,     0,    17,    56,    57,    18,
       0,    31,    19,    20,     0,    21,     1,     2,     3,     4,
      19,    70,     5,     6,   -67,   -67,   -67,   -67,     7,     8,
       0,   -66,   -66,   -66,   -66,   -65,   -65,   -65,   -65,     0,
       9,     0,    10,     0,     0,    84,    11,     0,     0,    12,
      93,    14,     0,     0,   -67,     0,    15,     4,    16,     0,
      17,   -66,     0,    18,     0,   -65,    19,    20,     0,    21,
     -69,   -69,   -69,   -69,   -67,   -68,   -68,   -68,   -68,     0,
      94,   -66,    95,     0,     0,   -65,     0,    94,     0,    95,
       0,     0,     0,     0,     0,     0,     0,    19,     0,    96,
     -69,     0,     0,     0,    19,   -68,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     -69,     0,     0,     0,     0,   -68,    54,    55,    56,    57,
      58,    59,    60,    61,    62,    63,    64,    65,    66,    67,
      68,    69,    70,    71,     0,     0,     0,     0,    72,     0,
      73,    74,     0,    92,    75,    76,    77,    78,     0,    79,
      80,     0,    81,     0,    82,    83,    84,     0,     0,    85,
       0,     0,     0,    86,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    64,    65,    66,    67,    68,    69,
      70,    71,     0,     0,     0,     0,    72,     0,    73,    74,
       0,   134,    75,    76,    77,    78,     0,    79,    80,     0,
      81,     0,    82,    83,    84,     0,     0,    85,     0,     0,
       0,    86,    54,    55,    56,    57,    58,    59,    60,    61,
      62,    63,    64,    65,    66,    67,    68,    69,    70,    71,
       0,     0,     0,     0,    72,     0,    73,    74,     0,     0,
      75,    76,    77,    78,     0,    79,    80,     0,    81,     0,
      82,    83,    84,     0,     0,    85,     0,     0,     0,    86,
      54,    55,    56,    57,    58,    59,    60,    61,    62,    63,
      64,    65,    66,    67,    68,    69,    70,    71,     0,     0,
       0,     0,    72,     0,    73,    74,     0,     0,    75,    76,
       0,    78,     0,    79,    80,     0,    81,     0,    82,    83,
      84,     0,     0,    85,     0,     0,     0,    86,    56,    57,
      58,    59,    60,    61,    62,    63,    64,    65,    66,    67,
      68,    69,    70,    71,     0,     0,     0,     0,    72,     0,
      73,    74,     0,     0,    75,    76,     0,    78,     0,    79,
      80,     0,    81,     0,    82,    83,    84,     0,     0,    85,
       0,    56,    57,    86,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,     0,     0,     0,
       0,    72,     0,    73,    74,     0,     0,    75,    76,     0,
      78,     0,    79,     0,     0,    81,     0,    82,     0,    84,
       0,     0,    85,    56,    57,     0,    86,    60,    61,    62,
      63,    64,    65,    66,    67,    68,    69,    70,    71,     0,
       0,     0,     0,    72,     0,    73,    74,     0,     0,    75,
      76,     0,    78,     0,    79,     0,     0,    81,     0,    82,
       0,    84,     0,     0,    85,    56,    57,     0,    86,    60,
      61,    62,    63,    64,    65,    66,    67,    68,     0,    70,
      71,     0,     0,     0,     0,    72,     0,    73,    74,     0,
       0,    75,    76,     0,    78,     0,    79,     0,     0,    81,
       0,    82,     0,    84,     0,     0,    85,    56,    57,     0,
      86,    60,    61,    62,    63,    64,    65,    66,    67,     0,
       0,    70,    71,     0,     0,     0,     0,    72,     0,    73,
      74,     0,     0,    75,    76,     0,    78,     0,    79,     0,
       0,    81,     0,    82,     0,    84,     0,     0,    85,    56,
      57,     0,    86,    60,    61,    62,    63,    64,    65,    66,
      67,     0,     0,    70,    71,     0,     0,     0,     0,    72,
       0,    73,    74,     0,     0,    75,    76,     0,    78,     0,
      79,     0,     0,    81,     0,    82,     0,    84,    56,    57,
      85,     0,    60,    61,    62,    63,    64,    65,    66,    67,
       0,     0,    70,    71,     0,     0,     0,     0,    72,     0,
      73,    74,     0,     0,    75,    76,     0,    78,     0,    79,
       0,     0,    81,     0,    82,     0,    84,    56,    57,     0,
       0,    60,    61,    62,    63,    64,    65,    66,    67,     0,
       0,    70,    71,     0,     0,     0,     0,    72,     0,    73,
       0,     0,     0,    75,    76,     0,    78,     0,    79,     0,
       0,    81,     0,    82,     0,    84,    56,    57,     0,     0,
       0,     0,    62,    63,    64,    65,    66,    67,     0,     0,
      70,    71,     0,     0,     0,     0,    72,     0,    73,     0,
       0,     0,    75,    76,     0,    78,     0,    79,    56,    57,
      81,     0,    82,     0,    84,     0,    64,    65,    66,    67,
       0,     0,    70,    71,     0,     0,     0,     0,    72,     0,
      73,     0,     0,     0,    75,    76,     0,    78,     0,    79,
      56,    57,     0,    56,    57,     0,    84,     0,    64,     0,
      66,     0,     0,     0,    70,    71,     0,    70,    71,     0,
      72,     0,    73,    72,     0,     0,    75,    76,     0,    78,
       0,    79,    56,    57,     0,     0,     0,     0,    84,     0,
       0,    84,    56,    57,     0,     0,    70,    71,     0,     0,
       0,     0,    72,     0,    73,     0,    70,    71,    75,    76,
       0,    78,    72,    79,    73,    56,    57,     0,    75,     0,
      84,     0,     0,    79,     0,     0,     0,     0,     0,    70,
      84,     0,     0,     0,     0,    72,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    84
};

static const short yycheck[] =
{
       2,    51,     5,     6,     7,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,     2,    20,    21,     2,
       2,    23,    30,    24,     0,     0,     7,    30,    31,    23,
     135,    -1,    -1,    -1,    -1,    -1,    -1,    23,    -1,    -1,
      23,    23,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    51,
      -1,    54,    55,    56,    57,    58,    59,    60,    61,    62,
      63,    64,    65,    66,    67,    68,    69,    70,    71,    72,
      73,    74,    75,    76,    77,    78,    79,    80,    81,    82,
      83,    84,    85,    86,    -1,   135,    -1,    -1,     4,     5,
       6,     7,    94,    95,    10,    11,     4,     5,     6,     7,
      16,    17,    -1,    -1,    -1,    -1,    -1,     4,     5,     6,
       7,    -1,    28,    -1,    30,    -1,    -1,    -1,    34,    35,
      -1,    37,    38,    39,    -1,    -1,    34,    -1,    44,    -1,
      46,    28,    48,   135,    -1,    51,    -1,    34,    54,    55,
      -1,    57,     4,     5,     6,     7,    54,    -1,    10,    11,
       4,     5,     6,     7,    16,    17,    -1,    54,    -1,    -1,
      57,    -1,    -1,    -1,    -1,    -1,    28,    -1,    30,    -1,
      -1,    -1,    34,    -1,    -1,    37,    38,    39,    -1,    -1,
      34,    -1,    44,    -1,    46,    -1,    48,    10,    11,    51,
      -1,    45,    54,    55,    -1,    57,     4,     5,     6,     7,
      54,    24,    10,    11,     4,     5,     6,     7,    16,    17,
      -1,     4,     5,     6,     7,     4,     5,     6,     7,    -1,
      28,    -1,    30,    -1,    -1,    48,    34,    -1,    -1,    37,
       7,    39,    -1,    -1,    34,    -1,    44,     7,    46,    -1,
      48,    34,    -1,    51,    -1,    34,    54,    55,    -1,    57,
       4,     5,     6,     7,    54,     4,     5,     6,     7,    -1,
      37,    54,    39,    -1,    -1,    54,    -1,    37,    -1,    39,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    54,    -1,    56,
      34,    -1,    -1,    -1,    54,    34,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      54,    -1,    -1,    -1,    -1,    54,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    -1,    -1,    -1,    -1,    30,    -1,
      32,    33,    -1,    35,    36,    37,    38,    39,    -1,    41,
      42,    -1,    44,    -1,    46,    47,    48,    -1,    -1,    51,
      -1,    -1,    -1,    55,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    -1,    -1,    -1,    -1,    30,    -1,    32,    33,
      -1,    35,    36,    37,    38,    39,    -1,    41,    42,    -1,
      44,    -1,    46,    47,    48,    -1,    -1,    51,    -1,    -1,
      -1,    55,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      -1,    -1,    -1,    -1,    30,    -1,    32,    33,    -1,    -1,
      36,    37,    38,    39,    -1,    41,    42,    -1,    44,    -1,
      46,    47,    48,    -1,    -1,    51,    -1,    -1,    -1,    55,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24,    25,    -1,    -1,
      -1,    -1,    30,    -1,    32,    33,    -1,    -1,    36,    37,
      -1,    39,    -1,    41,    42,    -1,    44,    -1,    46,    47,
      48,    -1,    -1,    51,    -1,    -1,    -1,    55,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    -1,    -1,    -1,    -1,    30,    -1,
      32,    33,    -1,    -1,    36,    37,    -1,    39,    -1,    41,
      42,    -1,    44,    -1,    46,    47,    48,    -1,    -1,    51,
      -1,    10,    11,    55,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    -1,    -1,    -1,
      -1,    30,    -1,    32,    33,    -1,    -1,    36,    37,    -1,
      39,    -1,    41,    -1,    -1,    44,    -1,    46,    -1,    48,
      -1,    -1,    51,    10,    11,    -1,    55,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    25,    -1,
      -1,    -1,    -1,    30,    -1,    32,    33,    -1,    -1,    36,
      37,    -1,    39,    -1,    41,    -1,    -1,    44,    -1,    46,
      -1,    48,    -1,    -1,    51,    10,    11,    -1,    55,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    -1,    -1,    -1,    -1,    30,    -1,    32,    33,    -1,
      -1,    36,    37,    -1,    39,    -1,    41,    -1,    -1,    44,
      -1,    46,    -1,    48,    -1,    -1,    51,    10,    11,    -1,
      55,    14,    15,    16,    17,    18,    19,    20,    21,    -1,
      -1,    24,    25,    -1,    -1,    -1,    -1,    30,    -1,    32,
      33,    -1,    -1,    36,    37,    -1,    39,    -1,    41,    -1,
      -1,    44,    -1,    46,    -1,    48,    -1,    -1,    51,    10,
      11,    -1,    55,    14,    15,    16,    17,    18,    19,    20,
      21,    -1,    -1,    24,    25,    -1,    -1,    -1,    -1,    30,
      -1,    32,    33,    -1,    -1,    36,    37,    -1,    39,    -1,
      41,    -1,    -1,    44,    -1,    46,    -1,    48,    10,    11,
      51,    -1,    14,    15,    16,    17,    18,    19,    20,    21,
      -1,    -1,    24,    25,    -1,    -1,    -1,    -1,    30,    -1,
      32,    33,    -1,    -1,    36,    37,    -1,    39,    -1,    41,
      -1,    -1,    44,    -1,    46,    -1,    48,    10,    11,    -1,
      -1,    14,    15,    16,    17,    18,    19,    20,    21,    -1,
      -1,    24,    25,    -1,    -1,    -1,    -1,    30,    -1,    32,
      -1,    -1,    -1,    36,    37,    -1,    39,    -1,    41,    -1,
      -1,    44,    -1,    46,    -1,    48,    10,    11,    -1,    -1,
      -1,    -1,    16,    17,    18,    19,    20,    21,    -1,    -1,
      24,    25,    -1,    -1,    -1,    -1,    30,    -1,    32,    -1,
      -1,    -1,    36,    37,    -1,    39,    -1,    41,    10,    11,
      44,    -1,    46,    -1,    48,    -1,    18,    19,    20,    21,
      -1,    -1,    24,    25,    -1,    -1,    -1,    -1,    30,    -1,
      32,    -1,    -1,    -1,    36,    37,    -1,    39,    -1,    41,
      10,    11,    -1,    10,    11,    -1,    48,    -1,    18,    -1,
      20,    -1,    -1,    -1,    24,    25,    -1,    24,    25,    -1,
      30,    -1,    32,    30,    -1,    -1,    36,    37,    -1,    39,
      -1,    41,    10,    11,    -1,    -1,    -1,    -1,    48,    -1,
      -1,    48,    10,    11,    -1,    -1,    24,    25,    -1,    -1,
      -1,    -1,    30,    -1,    32,    -1,    24,    25,    36,    37,
      -1,    39,    30,    41,    32,    10,    11,    -1,    36,    -1,
      48,    -1,    -1,    41,    -1,    -1,    -1,    -1,    -1,    24,
      48,    -1,    -1,    -1,    -1,    30,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    48
};
#define YYPURE 1

/* -*-C-*-  Note some compilers choke on comments on `#line' lines.  */
#line 3 "/usr/share/bison/bison.simple"

/* Skeleton output parser for bison,

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002 Free Software
   Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

/* This is the parser code that is written into each bison parser when
   the %semantic_parser declaration is not specified in the grammar.
   It was written by Richard Stallman by simplifying the hairy parser
   used when %semantic_parser is specified.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

#if ! defined (yyoverflow) || defined (YYERROR_VERBOSE)

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# if YYSTACK_USE_ALLOCA
#  define YYSTACK_ALLOC alloca
# else
#  ifndef YYSTACK_USE_ALLOCA
#   if defined (alloca) || defined (_ALLOCA_H)
#    define YYSTACK_ALLOC alloca
#   else
#    ifdef __GNUC__
#     define YYSTACK_ALLOC __builtin_alloca
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning. */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
# else
#  if defined (__STDC__) || defined (__cplusplus)
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   define YYSIZE_T size_t
#  endif
#  define YYSTACK_ALLOC malloc
#  define YYSTACK_FREE free
# endif
#endif /* ! defined (yyoverflow) || defined (YYERROR_VERBOSE) */


#if (! defined (yyoverflow) \
     && (! defined (__cplusplus) \
	 || (YYLTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  short yyss;
  YYSTYPE yyvs;
# if YYLSP_NEEDED
  YYLTYPE yyls;
# endif
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAX (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# if YYLSP_NEEDED
#  define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short) + sizeof (YYSTYPE) + sizeof (YYLTYPE))	\
      + 2 * YYSTACK_GAP_MAX)
# else
#  define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short) + sizeof (YYSTYPE))				\
      + YYSTACK_GAP_MAX)
# endif

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  register YYSIZE_T yyi;		\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (0)
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAX;	\
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (0)

#endif


#if ! defined (YYSIZE_T) && defined (__SIZE_TYPE__)
# define YYSIZE_T __SIZE_TYPE__
#endif
#if ! defined (YYSIZE_T) && defined (size_t)
# define YYSIZE_T size_t
#endif
#if ! defined (YYSIZE_T)
# if defined (__STDC__) || defined (__cplusplus)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# endif
#endif
#if ! defined (YYSIZE_T)
# define YYSIZE_T unsigned int
#endif

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		-2
#define YYEOF		0
#define YYACCEPT	goto yyacceptlab
#define YYABORT 	goto yyabortlab
#define YYERROR		goto yyerrlab1
/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */
#define YYFAIL		goto yyerrlab
#define YYRECOVERING()  (!!yyerrstatus)
#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yychar1 = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    { 								\
      yyerror ("syntax error: cannot back up");			\
      YYERROR;							\
    }								\
while (0)

#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Compute the default location (before the actions
   are run).

   When YYLLOC_DEFAULT is run, CURRENT is set the location of the
   first token.  By default, to implement support for ranges, extend
   its range to the last symbol.  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)       	\
   Current.last_line   = Rhs[N].last_line;	\
   Current.last_column = Rhs[N].last_column;
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#if YYPURE
# if YYLSP_NEEDED
#  ifdef YYLEX_PARAM
#   define YYLEX		yylex (&yylval, &yylloc, YYLEX_PARAM)
#  else
#   define YYLEX		yylex (&yylval, &yylloc)
#  endif
# else /* !YYLSP_NEEDED */
#  ifdef YYLEX_PARAM
#   define YYLEX		yylex (&yylval, YYLEX_PARAM)
#  else
#   define YYLEX		yylex (&yylval)
#  endif
# endif /* !YYLSP_NEEDED */
#else /* !YYPURE */
# define YYLEX			yylex ()
#endif /* !YYPURE */


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (0)
/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
#endif /* !YYDEBUG */

/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   SIZE_MAX < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#if YYMAXDEPTH == 0
# undef YYMAXDEPTH
#endif

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif

#ifdef YYERROR_VERBOSE

# ifndef yystrlen
#  if defined (__GLIBC__) && defined (_STRING_H)
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
#   if defined (__STDC__) || defined (__cplusplus)
yystrlen (const char *yystr)
#   else
yystrlen (yystr)
     const char *yystr;
#   endif
{
  register const char *yys = yystr;

  while (*yys++ != '\0')
    continue;

  return yys - yystr - 1;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined (__GLIBC__) && defined (_STRING_H) && defined (_GNU_SOURCE)
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
#   if defined (__STDC__) || defined (__cplusplus)
yystpcpy (char *yydest, const char *yysrc)
#   else
yystpcpy (yydest, yysrc)
     char *yydest;
     const char *yysrc;
#   endif
{
  register char *yyd = yydest;
  register const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif
#endif

#line 315 "/usr/share/bison/bison.simple"


/* The user can define YYPARSE_PARAM as the name of an argument to be passed
   into yyparse.  The argument should have type void *.
   It should actually point to an object.
   Grammar actions can access the variable by casting it
   to the proper pointer type.  */

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
#  define YYPARSE_PARAM_ARG void *YYPARSE_PARAM
#  define YYPARSE_PARAM_DECL
# else
#  define YYPARSE_PARAM_ARG YYPARSE_PARAM
#  define YYPARSE_PARAM_DECL void *YYPARSE_PARAM;
# endif
#else /* !YYPARSE_PARAM */
# define YYPARSE_PARAM_ARG
# define YYPARSE_PARAM_DECL
#endif /* !YYPARSE_PARAM */

/* Prevent warning if -Wstrict-prototypes.  */
#ifdef __GNUC__
# ifdef YYPARSE_PARAM
int yyparse (void *);
# else
int yyparse (void);
# endif
#endif

/* YY_DECL_VARIABLES -- depending whether we use a pure parser,
   variables are global, or local to YYPARSE.  */

#define YY_DECL_NON_LSP_VARIABLES			\
/* The lookahead symbol.  */				\
int yychar;						\
							\
/* The semantic value of the lookahead symbol. */	\
YYSTYPE yylval;						\
							\
/* Number of parse errors so far.  */			\
int yynerrs;

#if YYLSP_NEEDED
# define YY_DECL_VARIABLES			\
YY_DECL_NON_LSP_VARIABLES			\
						\
/* Location data for the lookahead symbol.  */	\
YYLTYPE yylloc;
#else
# define YY_DECL_VARIABLES			\
YY_DECL_NON_LSP_VARIABLES
#endif


/* If nonreentrant, generate the variables here. */

#if !YYPURE
YY_DECL_VARIABLES
#endif  /* !YYPURE */

int
yyparse (YYPARSE_PARAM_ARG)
     YYPARSE_PARAM_DECL
{
  /* If reentrant, generate the variables here. */
#if YYPURE
  YY_DECL_VARIABLES
#endif  /* !YYPURE */

  register int yystate;
  register int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Lookahead token as an internal (translated) token number.  */
  int yychar1 = 0;

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack. */
  short	yyssa[YYINITDEPTH];
  short *yyss = yyssa;
  register short *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  register YYSTYPE *yyvsp;

#if YYLSP_NEEDED
  /* The location stack.  */
  YYLTYPE yylsa[YYINITDEPTH];
  YYLTYPE *yyls = yylsa;
  YYLTYPE *yylsp;
#endif

#if YYLSP_NEEDED
# define YYPOPSTACK   (yyvsp--, yyssp--, yylsp--)
#else
# define YYPOPSTACK   (yyvsp--, yyssp--)
#endif

  YYSIZE_T yystacksize = YYINITDEPTH;


  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
#if YYLSP_NEEDED
  YYLTYPE yyloc;
#endif

  /* When reducing, the number of symbols on the RHS of the reduced
     rule. */
  int yylen;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;
#if YYLSP_NEEDED
  yylsp = yyls;
#endif
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed. so pushing a state here evens the stacks.
     */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyssp >= yyss + yystacksize - 1)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack. Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	short *yyss1 = yyss;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  */
# if YYLSP_NEEDED
	YYLTYPE *yyls1 = yyls;
	/* This used to be a conditional around just the two extra args,
	   but that might be undefined if yyoverflow is a macro.  */
	yyoverflow ("parser stack overflow",
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yyls1, yysize * sizeof (*yylsp),
		    &yystacksize);
	yyls = yyls1;
# else
	yyoverflow ("parser stack overflow",
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yystacksize);
# endif
	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyoverflowlab;
# else
      /* Extend the stack our own way.  */
      if (yystacksize >= YYMAXDEPTH)
	goto yyoverflowlab;
      yystacksize *= 2;
      if (yystacksize > YYMAXDEPTH)
	yystacksize = YYMAXDEPTH;

      {
	short *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyoverflowlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);
# if YYLSP_NEEDED
	YYSTACK_RELOCATE (yyls);
# endif
# undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
#if YYLSP_NEEDED
      yylsp = yyls + yysize - 1;
#endif

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyssp >= yyss + yystacksize - 1)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* yychar is either YYEMPTY or YYEOF
     or a valid token in external form.  */

  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  /* Convert token to internal form (in yychar1) for indexing tables with */

  if (yychar <= 0)		/* This means end of input. */
    {
      yychar1 = 0;
      yychar = YYEOF;		/* Don't call YYLEX any more */

      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yychar1 = YYTRANSLATE (yychar);

#if YYDEBUG
     /* We have to keep this `#if YYDEBUG', since we use variables
	which are defined only if `YYDEBUG' is set.  */
      if (yydebug)
	{
	  YYFPRINTF (stderr, "Next token is %d (%s",
		     yychar, yytname[yychar1]);
	  /* Give the individual parser a way to print the precise
	     meaning of a token, for further debugging info.  */
# ifdef YYPRINT
	  YYPRINT (stderr, yychar, yylval);
# endif
	  YYFPRINTF (stderr, ")\n");
	}
#endif
    }

  yyn += yychar1;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != yychar1)
    goto yydefault;

  yyn = yytable[yyn];

  /* yyn is what to do for this token type in this state.
     Negative => reduce, -yyn is rule number.
     Positive => shift, yyn is new state.
       New state is final state => don't bother to shift,
       just return success.
     0, or most negative number => error.  */

  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrlab;

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */
  YYDPRINTF ((stderr, "Shifting token %d (%s), ",
	      yychar, yytname[yychar1]));

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;
#if YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  yystate = yyn;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to the semantic value of
     the lookahead token.  This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];

#if YYLSP_NEEDED
  /* Similarly for the default location.  Let the user run additional
     commands if for instance locations are ranges.  */
  yyloc = yylsp[1-yylen];
  YYLLOC_DEFAULT (yyloc, (yylsp - yylen), yylen);
#endif

#if YYDEBUG
  /* We have to keep this `#if YYDEBUG', since we use variables which
     are defined only if `YYDEBUG' is set.  */
  if (yydebug)
    {
      int yyi;

      YYFPRINTF (stderr, "Reducing via rule %d (line %d), ",
		 yyn, yyrline[yyn]);

      /* Print the symbols being reduced, and their result.  */
      for (yyi = yyprhs[yyn]; yyrhs[yyi] > 0; yyi++)
	YYFPRINTF (stderr, "%s ", yytname[yyrhs[yyi]]);
      YYFPRINTF (stderr, " -> %s\n", yytname[yyr1[yyn]]);
    }
#endif

  switch (yyn) {

case 1:
#line 103 "napParse.y"
{yyval.str = Nap_SetParseResult(Nap_param, NULL);;
    break;}
case 2:
#line 104 "napParse.y"
{yyval.str = Nap_SetParseResult(Nap_param, yyvsp[0].pnode);;
    break;}
case 3:
#line 107 "napParse.y"
{yyval.pnode = Nap_NewNaoPNode(Nap_param, yyvsp[0].str);;
    break;}
case 4:
#line 108 "napParse.y"
{yyval.pnode = Nap_NewNaoPNode(Nap_param, yyvsp[0].str);;
    break;}
case 5:
#line 109 "napParse.y"
{yyval.pnode = Nap_NewNaoPNode(Nap_param, yyvsp[0].str);;
    break;}
case 6:
#line 110 "napParse.y"
{yyval.pnode = Nap_NewNaoPNode(Nap_param,
					    Nap_ScalarConstant(Nap_param, yyvsp[0].number));;
    break;}
case 7:
#line 112 "napParse.y"
{yyval.pnode = Nap_NewNamePNode(Nap_param, yyvsp[0].str);;
    break;}
case 8:
#line 113 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, 
					    Nap_NewNamePNode(Nap_param, yyvsp[-2].str), yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 9:
#line 115 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 10:
#line 116 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 11:
#line 117 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 12:
#line 118 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 13:
#line 119 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 14:
#line 120 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 15:
#line 121 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 16:
#line 122 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 17:
#line 123 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 18:
#line 124 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 19:
#line 125 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 20:
#line 126 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 21:
#line 127 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 22:
#line 128 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 23:
#line 129 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 24:
#line 130 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 25:
#line 131 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 26:
#line 132 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 27:
#line 133 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 28:
#line 134 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 29:
#line 135 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 30:
#line 136 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 31:
#line 137 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 32:
#line 138 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 33:
#line 139 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 34:
#line 140 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 35:
#line 141 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 36:
#line 142 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 37:
#line 143 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 38:
#line 144 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 39:
#line 145 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 40:
#line 146 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 41:
#line 147 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-2].pnode, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 42:
#line 148 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 43:
#line 149 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 44:
#line 150 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 45:
#line 151 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 46:
#line 152 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 47:
#line 153 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 48:
#line 154 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 49:
#line 155 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 50:
#line 156 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 51:
#line 157 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 52:
#line 158 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 53:
#line 159 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 54:
#line 160 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 55:
#line 161 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 56:
#line 162 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[-1].op, yyvsp[0].pnode);;
    break;}
case 57:
#line 163 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-1].pnode, yyvsp[0].op, NULL);;
    break;}
case 58:
#line 164 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[0].op, NULL);;
    break;}
case 59:
#line 165 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, yyvsp[0].op, NULL);;
    break;}
case 60:
#line 166 "napParse.y"
{yyval.pnode = yyvsp[-1].pnode;;
    break;}
case 61:
#line 167 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, 
					    Nap_NewNamePNode(Nap_param, yyvsp[-1].str), NULL_OP,
					    Nap_NewNamePNode(Nap_param, yyvsp[0].str));;
    break;}
case 62:
#line 170 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, 
					    Nap_NewNamePNode(Nap_param, yyvsp[-1].str), NULL_OP, yyvsp[0].pnode);;
    break;}
case 63:
#line 172 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-1].pnode, NULL_OP,
					    Nap_NewNamePNode(Nap_param, yyvsp[0].str));;
    break;}
case 64:
#line 175 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, yyvsp[-1].pnode, NULL_OP, yyvsp[0].pnode);;
    break;}
case 65:
#line 178 "napParse.y"
{yyval.pnode = Nap_NewNaoPNode(Nap_param, yyvsp[0].str);;
    break;}
case 66:
#line 179 "napParse.y"
{yyval.pnode = Nap_NewNaoPNode(Nap_param, yyvsp[0].str);;
    break;}
case 67:
#line 180 "napParse.y"
{yyval.pnode = Nap_NewNaoPNode(Nap_param, yyvsp[0].str);;
    break;}
case 68:
#line 181 "napParse.y"
{yyval.pnode = yyvsp[-1].pnode;;
    break;}
case 69:
#line 182 "napParse.y"
{yyval.pnode = Nap_NewNaoPNode(Nap_param,
					    Nap_ScalarConstant(Nap_param, yyvsp[0].number));;
    break;}
case 70:
#line 186 "napParse.y"
{yyval.pnode = Nap_NewNaoPNode(Nap_param, yyvsp[0].str);;
    break;}
case 71:
#line 187 "napParse.y"
{yyval.pnode = Nap_NewNaoPNode(Nap_param, yyvsp[0].str);;
    break;}
case 72:
#line 188 "napParse.y"
{yyval.pnode = Nap_NewNaoPNode(Nap_param, yyvsp[0].str);;
    break;}
case 73:
#line 189 "napParse.y"
{yyval.pnode = yyvsp[-1].pnode;;
    break;}
case 74:
#line 190 "napParse.y"
{yyval.pnode = Nap_NewExprPNode(Nap_param, NULL, NULL_OP, NULL);;
    break;}
case 75:
#line 191 "napParse.y"
{yyval.pnode = Nap_NewNaoPNode(Nap_param,
					    Nap_ScalarConstant(Nap_param, yyvsp[0].number));;
    break;}
case 76:
#line 195 "napParse.y"
{yyval.str = Nap_GetNaoIdFromId(Nap_param, yyvsp[0].str);;
    break;}
case 77:
#line 198 "napParse.y"
{yyval.str = Nap_StringConstant(Nap_param, yyvsp[0].str);;
    break;}
case 78:
#line 201 "napParse.y"
{yyval.str = Nap_ArrayConstant(Nap_param, yyvsp[0].pnode);;
    break;}
case 79:
#line 204 "napParse.y"
{yyval.pnode = yyvsp[-1].pnode ? yyvsp[-1].pnode :
						Nap_NewListPNode(Nap_param, "0", NULL);;
    break;}
case 80:
#line 208 "napParse.y"
{yyval.pnode = NULL;;
    break;}
case 81:
#line 209 "napParse.y"
{yyval.pnode = Nap_AppendToPNodeList(Nap_param, yyvsp[-1].pnode, yyvsp[0].pnode);;
    break;}
case 82:
#line 212 "napParse.y"
{yyval.pnode = Nap_NewValuePNode(Nap_param, "1", yyvsp[0].number);;
    break;}
case 83:
#line 213 "napParse.y"
{yyval.pnode = Nap_NewValuePNode(Nap_param, yyvsp[-2].str, yyvsp[0].number);;
    break;}
case 84:
#line 214 "napParse.y"
{yyval.pnode = Nap_NewListPNode(Nap_param, "1", yyvsp[0].pnode);;
    break;}
case 85:
#line 215 "napParse.y"
{yyval.pnode = Nap_NewListPNode(Nap_param, yyvsp[-2].str, yyvsp[0].pnode);;
    break;}
case 87:
#line 219 "napParse.y"
{yyval.number = Nap_NegateNumber(Nap_param, yyvsp[0].number);;
    break;}
case 88:
#line 220 "napParse.y"
{yyval.number = yyvsp[0].number;;
    break;}
case 89:
#line 223 "napParse.y"
{(void) Nap_StringToNumber(Nap_param, yyvsp[0].str, &(yyval.number));;
    break;}
}

#line 705 "/usr/share/bison/bison.simple"


  yyvsp -= yylen;
  yyssp -= yylen;
#if YYLSP_NEEDED
  yylsp -= yylen;
#endif

#if YYDEBUG
  if (yydebug)
    {
      short *yyssp1 = yyss - 1;
      YYFPRINTF (stderr, "state stack now");
      while (yyssp1 != yyssp)
	YYFPRINTF (stderr, " %d", *++yyssp1);
      YYFPRINTF (stderr, "\n");
    }
#endif

  *++yyvsp = yyval;
#if YYLSP_NEEDED
  *++yylsp = yyloc;
#endif

  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTBASE] + *yyssp;
  if (yystate >= 0 && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTBASE];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;

#ifdef YYERROR_VERBOSE
      yyn = yypact[yystate];

      if (yyn > YYFLAG && yyn < YYLAST)
	{
	  YYSIZE_T yysize = 0;
	  char *yymsg;
	  int yyx, yycount;

	  yycount = 0;
	  /* Start YYX at -YYN if negative to avoid negative indexes in
	     YYCHECK.  */
	  for (yyx = yyn < 0 ? -yyn : 0;
	       yyx < (int) (sizeof (yytname) / sizeof (char *)); yyx++)
	    if (yycheck[yyx + yyn] == yyx)
	      yysize += yystrlen (yytname[yyx]) + 15, yycount++;
	  yysize += yystrlen ("parse error, unexpected ") + 1;
	  yysize += yystrlen (yytname[YYTRANSLATE (yychar)]);
	  yymsg = (char *) YYSTACK_ALLOC (yysize);
	  if (yymsg != 0)
	    {
	      char *yyp = yystpcpy (yymsg, "parse error, unexpected ");
	      yyp = yystpcpy (yyp, yytname[YYTRANSLATE (yychar)]);

	      if (yycount < 5)
		{
		  yycount = 0;
		  for (yyx = yyn < 0 ? -yyn : 0;
		       yyx < (int) (sizeof (yytname) / sizeof (char *));
		       yyx++)
		    if (yycheck[yyx + yyn] == yyx)
		      {
			const char *yyq = ! yycount ? ", expecting " : " or ";
			yyp = yystpcpy (yyp, yyq);
			yyp = yystpcpy (yyp, yytname[yyx]);
			yycount++;
		      }
		}
	      yyerror (yymsg);
	      YYSTACK_FREE (yymsg);
	    }
	  else
	    yyerror ("parse error; also virtual memory exhausted");
	}
      else
#endif /* defined (YYERROR_VERBOSE) */
	yyerror ("parse error");
    }
  goto yyerrlab1;


/*--------------------------------------------------.
| yyerrlab1 -- error raised explicitly by an action |
`--------------------------------------------------*/
yyerrlab1:
  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
	 error, discard it.  */

      /* return failure if at end of input */
      if (yychar == YYEOF)
	YYABORT;
      YYDPRINTF ((stderr, "Discarding token %d (%s).\n",
		  yychar, yytname[yychar1]));
      yychar = YYEMPTY;
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */

  yyerrstatus = 3;		/* Each real token shifted decrements this */

  goto yyerrhandle;


/*-------------------------------------------------------------------.
| yyerrdefault -- current state does not do anything special for the |
| error token.                                                       |
`-------------------------------------------------------------------*/
yyerrdefault:
#if 0
  /* This is wrong; only states that explicitly want error tokens
     should shift them.  */

  /* If its default is to accept any token, ok.  Otherwise pop it.  */
  yyn = yydefact[yystate];
  if (yyn)
    goto yydefault;
#endif


/*---------------------------------------------------------------.
| yyerrpop -- pop the current state because it cannot handle the |
| error token                                                    |
`---------------------------------------------------------------*/
yyerrpop:
  if (yyssp == yyss)
    YYABORT;
  yyvsp--;
  yystate = *--yyssp;
#if YYLSP_NEEDED
  yylsp--;
#endif

#if YYDEBUG
  if (yydebug)
    {
      short *yyssp1 = yyss - 1;
      YYFPRINTF (stderr, "Error: state stack now");
      while (yyssp1 != yyssp)
	YYFPRINTF (stderr, " %d", *++yyssp1);
      YYFPRINTF (stderr, "\n");
    }
#endif

/*--------------.
| yyerrhandle.  |
`--------------*/
yyerrhandle:
  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yyerrdefault;

  yyn += YYTERROR;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != YYTERROR)
    goto yyerrdefault;

  yyn = yytable[yyn];
  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrpop;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrpop;

  if (yyn == YYFINAL)
    YYACCEPT;

  YYDPRINTF ((stderr, "Shifting error token, "));

  *++yyvsp = yylval;
#if YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

/*---------------------------------------------.
| yyoverflowab -- parser overflow comes here.  |
`---------------------------------------------*/
yyoverflowlab:
  yyerror ("parser stack overflow");
  yyresult = 2;
  /* Fall through.  */

yyreturn:
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
  return yyresult;
}
#line 226 "napParse.y"

