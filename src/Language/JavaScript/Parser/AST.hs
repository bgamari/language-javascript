{-# LANGUAGE DeriveDataTypeable #-}
module Language.JavaScript.Parser.AST
       (
           JSNode (..)
         , JSAnnot (..)
         , showStripped
       ) where

import Data.Data
import Data.List
import Language.JavaScript.Parser.SrcLocation (TokenPosn(..))
import Language.JavaScript.Parser.Token

-- ---------------------------------------------------------------------

data JSAnnot = JSAnnot TokenPosn [CommentAnnotation]-- ^Annotation: position and comment/whitespace information
             | JSNoAnnot -- ^No annotation
    deriving (Eq, Read, Data, Typeable)

instance Show JSAnnot where
    show JSNoAnnot = "NoAnnot"
    show (JSAnnot pos cs) = "Annot (" ++ show pos ++ ") " ++ show cs

-- |The JSNode is the building block of the AST.
-- Each has a syntactic part 'Node'. In addition, the leaf elements
-- (terminals) have a position 'TokenPosn', as well as an array of comments
-- and/or whitespace that was collected while parsing.

data JSNode =
              -- | Terminals
                JSIdentifier JSAnnot String
              | JSDecimal JSAnnot String
              | JSLiteral JSAnnot String
              | JSHexInteger JSAnnot String
              | JSOctal JSAnnot String
              | JSStringLiteral JSAnnot Char String
              | JSRegEx JSAnnot String

              -- | Non Terminals

              | JSArguments JSAnnot JSNode [JSNode] JSNode    -- ^lb, args, rb
              | JSArrayLiteral JSAnnot JSNode [JSNode] JSNode -- ^lb, contents, rb
              | JSBlock JSAnnot [JSNode] [JSNode] [JSNode]      -- ^optional lb,optional block statements,optional rb
              | JSBreak JSAnnot JSNode [JSNode] JSNode        -- ^break, optional identifier, autosemi
              | JSCallExpression JSAnnot String [JSNode] [JSNode] [JSNode]  -- ^type : ., (), []; opening [ or ., contents, closing
              | JSCase JSAnnot JSNode JSNode JSNode [JSNode]    -- ^case,expr,colon,stmtlist
              | JSCatch JSAnnot JSNode JSNode JSNode [JSNode] JSNode JSNode -- ^ catch,lb,ident,[if,expr],rb,block
              | JSContinue JSAnnot JSNode [JSNode] JSNode     -- ^continue,optional identifier,autosemi
              | JSDefault JSAnnot JSNode JSNode [JSNode] -- ^default,colon,stmtlist
              | JSDoWhile JSAnnot JSNode JSNode JSNode JSNode JSNode JSNode JSNode -- ^do,stmt,while,lb,expr,rb,autosemi
              | JSElision JSAnnot JSNode               -- ^comma
              | JSExpression JSAnnot [JSNode]          -- ^expression components
              | JSExpressionAssign JSAnnot [JSNode] JSNode [JSNode] -- ^lhs, assignop, rhs
              | JSExpressionBinary JSAnnot String [JSNode] JSNode [JSNode] -- ^what, lhs, op, rhs
              | JSExpressionParen JSAnnot JSNode JSNode JSNode -- ^lb,expression,rb
              | JSExpressionPostfix JSAnnot String [JSNode] JSNode -- ^type, expression, operator
              | JSExpressionTernary JSAnnot [JSNode] JSNode [JSNode] JSNode [JSNode] -- ^cond, ?, trueval, :, falseval
              | JSFinally JSAnnot JSNode JSNode -- ^finally,block
              | JSFor JSAnnot JSNode JSNode [JSNode] JSNode [JSNode] JSNode [JSNode] JSNode JSNode -- ^for,lb,expr,semi,expr,semi,expr,rb.stmt
              | JSForIn JSAnnot JSNode JSNode [JSNode] JSNode JSNode JSNode JSNode -- ^for,lb,expr,in,expr,rb,stmt
              | JSForVar JSAnnot JSNode JSNode JSNode [JSNode] JSNode [JSNode] JSNode [JSNode] JSNode JSNode -- ^for,lb,var,vardecl,semi,expr,semi,expr,rb,stmt
              | JSForVarIn JSAnnot JSNode JSNode JSNode JSNode JSNode JSNode JSNode JSNode -- ^for,lb,var,vardecl,in,expr,rb,stmt
              | JSFunction JSAnnot JSNode JSNode JSNode [JSNode] JSNode JSNode  -- ^fn,name, lb,parameter list,rb,block
              | JSFunctionExpression JSAnnot JSNode [JSNode] JSNode [JSNode] JSNode JSNode  -- ^fn,[name],lb, parameter list,rb,block`
              | JSIf JSAnnot JSNode JSNode JSNode JSNode [JSNode] [JSNode] -- ^if,(,expr,),stmt,optional rest
              | JSLabelled JSAnnot JSNode JSNode JSNode -- ^identifier,colon,stmt
              | JSMemberDot JSAnnot [JSNode] JSNode JSNode -- ^firstpart, dot, name
              | JSMemberSquare JSAnnot [JSNode] JSNode JSNode JSNode -- ^firstpart, lb, expr, rb
              | JSObjectLiteral JSAnnot JSNode [JSNode] JSNode -- ^lbrace contents rbrace
              | JSOperator JSAnnot JSNode -- ^opnode
              | JSPropertyAccessor JSAnnot JSNode JSNode JSNode [JSNode] JSNode JSNode -- ^(get|set), name, lb, params, rb, block
              | JSPropertyNameandValue JSAnnot JSNode JSNode [JSNode] -- ^name, colon, value
              | JSReturn JSAnnot JSNode [JSNode] JSNode -- ^return,optional expression,autosemi

              | JSSourceElementsTop JSAnnot [JSNode] -- ^source elements
              | JSSwitch JSAnnot JSNode JSNode JSNode JSNode JSNode -- ^switch,lb,expr,rb,caseblock
              | JSThrow JSAnnot JSNode JSNode -- ^throw val
              | JSTry JSAnnot JSNode JSNode [JSNode] -- ^try,block,rest
              | JSUnary JSAnnot String JSNode -- ^type, operator
              | JSVarDecl JSAnnot JSNode [JSNode] -- ^identifier, optional initializer
              | JSVariables JSAnnot JSNode [JSNode] JSNode -- ^var|const, decl, autosemi
              | JSWhile JSAnnot JSNode JSNode JSNode JSNode JSNode -- ^while,lb,expr,rb,stmt
              | JSWith JSAnnot JSNode JSNode JSNode JSNode [JSNode] -- ^with,lb,expr,rb,stmt list
    deriving (Show, Eq, Read, Data, Typeable)

-- Strip out the location info, leaving the original JSNode text representation
showStripped :: JSNode -> String
showStripped = ss

ss :: JSNode -> String
ss (JSArguments _ _lb xs _rb) = "JSArguments " ++ sss xs
ss (JSArrayLiteral _ _lb xs _rb) = "JSArrayLiteral " ++ sss xs
ss (JSBlock _ _lb xs _rb) = "JSBlock (" ++ sss xs ++ ")"
ss (JSBreak _ _b x1s as) = "JSBreak " ++ sss x1s ++ " " ++ ss as
ss (JSCallExpression _ s _os xs _cs) = "JSCallExpression " ++ show s ++ " " ++ sss xs
ss (JSCase _ _ca x1 _c x2s) = "JSCase (" ++ ss x1 ++ ") (" ++ sss x2s ++ ")"
ss (JSCatch _ _c _lb x1 x2s _rb x3) = "JSCatch (" ++ ss x1 ++ ") " ++ sss x2s ++ " (" ++ ss x3 ++ ")"
ss (JSContinue _ _c xs as) = "JSContinue " ++ sss xs ++ " " ++ ss as
ss (JSDecimal _ s) = "JSDecimal " ++ show s
ss (JSDefault _ _d _c xs) = "JSDefault (" ++ sss xs ++ ")"
ss (JSDoWhile _ _d x1 _w _lb x2 _rb x3) = "JSDoWhile (" ++ ss x1 ++ ") (" ++ ss x2 ++ ") (" ++ ss x3 ++ ")"
ss (JSElision _ c) = "JSElision " ++ ss c
ss (JSExpression _ xs) = "JSExpression " ++ sss xs
ss (JSExpressionAssign _ x2s op x3s) = "JSExpressionAssign " ++ sss x2s ++ " " ++ ss op ++ " " ++ sss x3s
ss (JSExpressionBinary _ s x2s _op x3s) = "JSExpressionBinary " ++ show s ++ " " ++ sss x2s ++ " " ++ sss x3s
ss (JSExpressionParen _ _lp x _rp) = "JSExpressionParen (" ++ ss x ++ ")"
ss (JSExpressionPostfix _ s xs _op) = "JSExpressionPostfix " ++ show s ++ " " ++ sss xs
ss (JSExpressionTernary _ x1s _q x2s _c x3s) = "JSExpressionTernary " ++ sss x1s ++ " " ++ sss x2s ++ " " ++ sss x3s
ss (JSFinally _ _f x) = "JSFinally (" ++ ss x ++ ")"
ss (JSFor _ _f _lb x1s _s1 x2s _s2 x3s _rb x4) = "JSFor " ++ sss x1s ++ " " ++ sss x2s ++ " " ++ sss x3s ++ " (" ++ ss x4 ++ ")"
ss (JSForIn _ _f _lb x1s _i x2 _rb x3) = "JSForIn " ++ sss x1s ++ " (" ++ ss x2 ++ ") (" ++ ss x3 ++ ")"
ss (JSForVar _ _f _lb _v x1s _s1 x2s _s2 x3s _rb x4) = "JSForVar " ++ sss x1s ++ " " ++ sss x2s ++ " " ++ sss x3s ++ " (" ++ ss x4 ++ ")"
ss (JSForVarIn _ _f _lb _v x1 _i x2 _rb x3) = "JSForVarIn (" ++ ss x1 ++ ") (" ++ ss x2 ++ ") (" ++ ss x3 ++ ")"
ss (JSFunction _ _f x1 _lb x2s _rb x3) = "JSFunction (" ++ ss x1 ++ ") " ++ sss x2s ++ " (" ++ ss x3 ++ ")"
ss (JSFunctionExpression _ _f x1s _lb x2s _rb x3) = "JSFunctionExpression " ++ sss x1s ++ " " ++ sss x2s ++ " (" ++ ss x3 ++ ")"
ss (JSHexInteger _ s) = "JSHexInteger " ++ show s
ss (JSOctal _ s) = "JSOctal " ++ show s
ss (JSIdentifier _ s) = "JSIdentifier " ++ show s
ss (JSIf _ _i _lb x1 _rb x2s x3s) = "JSIf (" ++ ss x1 ++ ") (" ++ sss x2s ++ ") (" ++ sss x3s ++ ")"
ss (JSLabelled _ x1 _c x2) = "JSLabelled (" ++ ss x1 ++ ") (" ++ ss x2 ++ ")"
ss (JSLiteral _ s) = "JSLiteral " ++ show s
ss (JSMemberDot _ x1s _d x2 ) = "JSMemberDot " ++ sss x1s ++ " (" ++ ss x2 ++ ")"
ss (JSMemberSquare _ x1s _lb x2 _rb) = "JSMemberSquare " ++ sss x1s ++ " (" ++ ss x2 ++ ")"
ss (JSObjectLiteral _ _lb xs _rb) = "JSObjectLiteral " ++ sss xs
ss (JSOperator _ n) = "JSOperator " ++ ss n
ss (JSPropertyNameandValue _ x1 _colon x2s) = "JSPropertyNameandValue (" ++ ss x1 ++ ") " ++ sss x2s
ss (JSPropertyAccessor _ s x1 _lb1 x2s _rb1 x3) = "JSPropertyAccessor " ++ show s ++ " (" ++ ss x1 ++ ") " ++ sss x2s ++ " (" ++ ss x3 ++ ")"
ss (JSRegEx _ s) = "JSRegEx " ++ show s
ss (JSReturn _ _r xs as) = "JSReturn " ++ sss xs ++ " " ++ ss as
ss (JSSourceElementsTop _ xs) = "JSSourceElementsTop " ++ sss xs
ss (JSStringLiteral _ c s) = "JSStringLiteral " ++ show c ++ " " ++ show s
ss (JSSwitch _ _s _lb x _rb x2) = "JSSwitch (" ++ ss x ++ ") " ++ ss x2
ss (JSThrow _ _t x) = "JSThrow (" ++ ss x ++ ")"
ss (JSTry _ _t x1 x2s) = "JSTry (" ++ ss x1 ++ ") " ++ sss x2s
ss (JSUnary _ s _x) = "JSUnary " ++ show s
ss (JSVarDecl _ x1 x2s) = "JSVarDecl (" ++ ss x1 ++ ") " ++ sss x2s
ss (JSVariables _ n xs _as) = "JSVariables " ++ ss n ++ " " ++ sss xs
ss (JSWhile _ _w _lb x1 _rb x2) = "JSWhile (" ++ ss x1 ++ ") (" ++ ss x2 ++ ")"
ss (JSWith _ _w _lb x1 _rb x2s) = "JSWith (" ++ ss x1 ++ ") " ++ sss x2s

sss :: [JSNode] -> String
sss xs = "[" ++ (concat (intersperse "," $ map ss xs)) ++ "]"

-- EOF
