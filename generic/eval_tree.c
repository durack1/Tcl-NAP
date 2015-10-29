/*
 * eval_tree.c --
 *
 * Evaluate parse tree & set Tcl result
 *
 * Copyright 2005, CSIRO Australia
 * Author: Harvey Davies, CSIRO Atmospheric Research.
 */

#ifndef lint
static char *rcsid="@(#) $Id: eval_tree.c,v 1.5 2005/06/23 08:21:29 dav480 Exp $";
#endif /* not lint */

#include "nap.h"
#include "nap_check.h"
#include "napParse.tab.h"

static char *eval_tree(NapClientData	*nap_cd, Nap_PNode *expr);

/*
 * expr1 --
 *
 * Evaluate monadic operator (1 operand)
 *
 * Result is NAO ID of expression result
 */

#undef TEXT0
#define TEXT0 "expr1: "

static char *
expr1(
    NapClientData	*nap_cd,
    int			op,
    char		*right)
{
    char		*fmt_c = TEXT0 "Error with unary operator '%c'";
    char		*fmt_s = TEXT0 "Error with unary operator '%s'";
    char		*id;		/* OOC-name of NAO */

    switch (op) {
	case '!':     id = Nap_Not(nap_cd, right); CHECK3NULL(id, fmt_c, op); break;
	case '#':     id = Nap_Tally(nap_cd, right); CHECK3NULL(id, fmt_c, op); break;
	case '-':     id = Nap_Negate(nap_cd, right); CHECK3NULL(id, fmt_c, op); break;
	case '~':     id = Nap_Complement(nap_cd, right); CHECK3NULL(id, fmt_c, op); break;
	case '+':     id = Nap_Identity(nap_cd, right); CHECK3NULL(id, fmt_c, op); break;
	case '^':     id = Nap_Round(nap_cd, right); CHECK3NULL(id, fmt_c, op); break;
	case '<':     id = Nap_Floor(nap_cd, right); CHECK3NULL(id, fmt_c, op); break;
	case '>':     id = Nap_Ceil(nap_cd, right); CHECK3NULL(id, fmt_c, op); break;
	case '|':     id = Nap_Func(nap_cd, "abs", right); CHECK3NULL(id, fmt_c, op); break;
	case ',':     id = Nap_Link(nap_cd, NULL, right); CHECK3NULL(id, fmt_c, op); break;
	case '@':     id = Nap_Indirect(nap_cd, op, right); CHECK3NULL(id, fmt_c, op); break;
	case CLOSEST: id = Nap_Indirect(nap_cd, op, right); CHECK3NULL(id, fmt_s, "@@"); break;
	case MATCH:   id = Nap_Indirect(nap_cd, op, right); CHECK3NULL(id, fmt_s, "@@@"); break;
	default: CHECK3NULL(0, TEXT0 "NAP_EXPR node has unexpected unary operator %c", op);
    }
    return id;
}

/*
 * expr2 --
 *
 * Evaluate dyadic operator (2 operands)
 *
 * Result is NAO ID of expression result
 */

#undef TEXT0
#define TEXT0 "expr2: "

static char *
expr2(
    NapClientData	*nap_cd,
    char		*left,
    int			op,
    char		*right)
{
    char		*fmt_c = TEXT0 "Error with binary operator '%c'";
    char		*fmt_s = TEXT0 "Error with binary operator '%s'";
    char		*id;		/* OOC-name of NAO */

    assert(left);
    switch (op) {
	case ':':
	    id = Nap_Link(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case ',':
	    id = Nap_Link(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case CAT:
	    id = Nap_Cat(nap_cd, left, right); CHECK3NULL(id, fmt_s, "//"); break;
	case LAMINATE:
	    id = Nap_Laminate(nap_cd, left, right); CHECK3NULL(id, fmt_s, "///"); break;
	case '@':
	    id = Nap_IndexOf2(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case '#':
	    id = Nap_Copy(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case CLOSEST:
	    id = Nap_Closest(nap_cd, left, right); CHECK3NULL(id, fmt_s, "@@"); break;
	case MATCH:
	    id = Nap_Match(nap_cd, left, right); CHECK3NULL(id, fmt_s, "@@@"); break;
	case '?':
	    id = Nap_Choice(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case TO:
	    id = Nap_AP(nap_cd, left, right); CHECK3NULL(id, fmt_s, ".."); break;
	case AP3:
	    id = Nap_Link(nap_cd, left, right); CHECK3NULL(id, fmt_s, "..."); break;
	case OR:
	    id = Nap_Or(nap_cd, left, right); CHECK3NULL(id, fmt_s, "||"); break;
	case AND:
	    id = Nap_And(nap_cd, left, right); CHECK3NULL(id, fmt_s, "&&"); break;
	case EQ:
	    id = Nap_Eq(nap_cd, left, right); CHECK3NULL(id, fmt_s, "=="); break;
	case NE:
	    id = Nap_Ne(nap_cd, left, right); CHECK3NULL(id, fmt_s, "!="); break;
	case LE:
	    id = Nap_Le(nap_cd, left, right); CHECK3NULL(id, fmt_s, "<="); break;
	case LESSER_OF:
	    id = Nap_LesserOf(nap_cd, left, right); CHECK3NULL(id, fmt_s, "<<<"); break;
	case GREATER_OF:
	    id = Nap_GreaterOf(nap_cd, left, right); CHECK3NULL(id, fmt_s, ">>>"); break;
	case '<':
	    id = Nap_Lt(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case GE:
	    id = Nap_Ge(nap_cd, left, right); CHECK3NULL(id, fmt_s, ">="); break;
	case '>':
	    id = Nap_Gt(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case '+':
	    id = Nap_Add(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case '-':
	    id = Nap_Sub(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case '*':
	    id = Nap_Mul(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case '/':
	    id = Nap_Div(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case '%':
	    id = Nap_Rem(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case INNER_PROD:
	    id = Nap_InnerProd(nap_cd, left, right); CHECK3NULL(id, fmt_s, "."); break;
	case POWER:
	    id = Nap_Power(nap_cd, left, right); CHECK3NULL(id, fmt_s, "**"); break;
	case '&':
	    id = Nap_BitAnd(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case '|':
	    id = Nap_BitOr(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case '^':
	    id = Nap_BitXor(nap_cd, left, right); CHECK3NULL(id, fmt_c, op); break;
	case SHIFT_LEFT:
	    id = Nap_ShiftLeft(nap_cd, left, right); CHECK3NULL(id, fmt_s, "<<"); break;
	case SHIFT_RIGHT:
	    id = Nap_ShiftRight(nap_cd, left, right); CHECK3NULL(id, fmt_s, ">>"); break;
	default: CHECK3NULL(0, TEXT0 "NAP_EXPR node has unexpected binary operator %c", op);
    }
    return id;
}

/*
 * eval_index --
 *
 * Evaluate array index in manner that allows unary operators such as @ to be evaluated
 * Result is NAO ID of expression result
 */

#undef TEXT0
#define TEXT0 "eval_index: "

static char *
eval_index(
    NapClientData	*nap_cd,
    Nap_PNode		*expr)
{
    Nap_NAO		*indexBaseCV;
    char		*left;
    int			level;		/* parse level */
    char		*right;
    char		*id;		/* OOC-name of NAO */

    level = nap_cd->parseLevel;
    assert(nap_cd->indexBaseCV);
    indexBaseCV = nap_cd->indexBaseCV[level];
    if (expr) {
	nap_cd->token[level] = expr->scanPtr;
	if (expr->class == NAP_NAO) {
	    id = expr->str;
	} else if (expr->class == NAP_EXPR  &&  expr->op == ',') {
	    left  = eval_index(nap_cd, expr->left);
	    ++nap_cd->indexDimNum[level];
	    if (!indexBaseCV  ||  nap_cd->indexDimNum[level] < indexBaseCV->nels) {
		right = eval_index(nap_cd, expr->right);
		id = Nap_Link(nap_cd, left, right);
	    } else {
		id = NULL;
	    }
	} else {
	    id = eval_tree(nap_cd, expr);
	}
    } else {
	id = NULL;
    }
    return id;
}

/*
 * eval_expr --
 *
 * Evaluate NAP_EXPR node
 *
 * Result is NAO ID of expression result
 */

#undef TEXT0
#define TEXT0 "eval_expr: "

static char *
eval_expr(
    NapClientData	*nap_cd,
    Nap_PNode		*expr)
{
    char		*left;
    int			level;		/* parse level */
    char		*right;
    char		*id;		/* OOC-name of NAO */
    Nap_NAO		*naoPtr;
    int			status;

    level = nap_cd->parseLevel;
    nap_cd->token[level] = expr->scanPtr;
    if (expr) {
	assert(expr->class == NAP_EXPR);
	if (expr->op == '=') {
	    CHECK2NULL(expr->left->class == NAP_NAME, TEXT0 "Left operand of '=' not name");
	    right = eval_tree(nap_cd, expr->right);
	    id = Nap_Assign(nap_cd, expr->left->str, right);
	} else {
	    if (expr->op == NULL_OP) {
		if (expr->left) {
		    if (expr->left->class == NAP_NAME) {
			status = Nap_Substitute(nap_cd, expr->left->str, &left);
		    } else {
			left = eval_tree(nap_cd, expr->left);
			status = 1;
		    }
		    switch (status) {
			case 1:
			    naoPtr = Nap_GetNaoFromId(nap_cd, left);
			    nap_cd->indexBaseCV[level] = naoPtr->boxedCV;
			    nap_cd->indexDimNum[level] = 0;
			    right = eval_index(nap_cd, expr->right);
			    nap_cd->indexBaseCV[level] = NULL;
			    id = Nap_Index(nap_cd, left, right);
			    break;
			case 2:
			    right = eval_tree(nap_cd, expr->right);
			    id = Nap_Func(nap_cd, left, right);
			    break;
			default:
			    CHECK2NULL(0, TEXT0 "Error calling Nap_Substitute");
		    }
		} else {		/* expression "()" */
		    assert(!expr->right);
		    id = NULL;
		}
	    } else {
		left = eval_tree(nap_cd, expr->left);
		right = eval_tree(nap_cd, expr->right);
		if (left) {
		    id = expr2(nap_cd, left, expr->op, right);
		} else if (right) {
		    id = expr1(nap_cd, expr->op, right);
		} else {
		    id = Nap_Niladic(nap_cd, expr->op);
		}
	    }
	}
    } else {
	id = NULL;
    }
    return id;
}

/*
 * eval_tree --
 *
 * Evaluate expression parse tree
 *
 * Result is NAO ID of expression result
 */

#undef TEXT0
#define TEXT0 "eval_tree: "

static char *
eval_tree(
    NapClientData	*nap_cd,
    Nap_PNode		*expr)
{
    char		*id;		/* OOC-name of NAO */

    if (expr) {
	switch (expr->class) {
	    case NAP_EXPR:
		id = eval_expr(nap_cd, expr);
		break;
	    case NAP_NAO:
		id = expr->str;
		break;
	    case NAP_NAME:
		id = Nap_GetNaoIdFromId(nap_cd, expr->str);
		break;
	    default:
		CHECK2NULL(0, TEXT0 "Parse node has unexpected type");
	}
    } else {
	id = NULL;
    }
    return id;
}

/*
 * Nap_SetParseResult --
 *
 * Evaluate parse tree & set nap_cd->resultNao to NAO ID of expression result
 */

#undef TEXT0
#define TEXT0 "Nap_SetParseResult: "

EXTERN char *
Nap_SetParseResult(
    NapClientData	*nap_cd,
    Nap_PNode		*expr)		/* result from parser */
{
    char		*id;		/* OOC-name of NAO */
    int			level;		/* parse level */

    CHECK2NULL(expr, TEXT0 "Result undefined");
    level = nap_cd->parseLevel;
    if (nap_cd->indexBaseCV[level]) {
	id = eval_index(nap_cd, expr);
    } else {
	id = eval_tree(nap_cd, expr);
    }
    nap_cd->resultNao = Nap_GetNaoFromId(nap_cd, id);
    Nap_FreePNodeTree(nap_cd, expr);
    return id;
}
