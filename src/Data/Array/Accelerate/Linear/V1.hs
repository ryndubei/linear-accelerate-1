{-# LANGUAGE ConstraintKinds       #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PatternSynonyms       #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE UndecidableInstances  #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
-----------------------------------------------------------------------------
-- |
-- Module      : Data.Array.Accelerate.Linear.V1
-- Copyright   : 2014 Edward Kmett, Charles Durham,
--               [2015..2020] Trevor L. McDonell
-- License     : BSD-style (see the file LICENSE)
--
-- Maintainer  : Trevor L. McDonell <trevor.mcdonell@gmail.com>
-- Stability   : experimental
-- Portability : non-portable
--
-- 1-D Vectors
----------------------------------------------------------------------------

module Data.Array.Accelerate.Linear.V1 (

  V1(..), pattern V1_,
  R1(..),
  ex,

) where

import Data.Array.Accelerate                    as A
import Data.Array.Accelerate.Data.Functor       as A

import Data.Array.Accelerate.Linear.Epsilon
import Data.Array.Accelerate.Linear.Lift
import Data.Array.Accelerate.Linear.Metric
import Data.Array.Accelerate.Linear.Type
import Data.Array.Accelerate.Linear.Vector

import Control.Lens
import Linear.V1                                ( V1(..) )
import Prelude                                  as P
import qualified Linear.V1                      as L

-- $setup
-- >>> import Data.Array.Accelerate.Interpreter
-- >>> :{
--   let test :: Elt e => Exp e -> e
--       test e = indexArray (run (unit e)) Z
-- :}


-- | A space that has at least 1 basis vector '_x'.
--
class L.R1 t => R1 t where
  -- |
  -- >>> test $ (V1_ 2 :: Exp (V1 Int)) ^. _x
  -- 2
  --
  -- >>> test $ (V1_ 2 :: Exp (V1 Int)) & _x .~ 3
  -- V1 3
  --
  _x :: (Elt a, Box t a) => Lens' (Exp (t a)) (Exp a)
  _x = liftLens (L._x :: Lens' (t (Exp a)) (Exp a))


ex :: R1 t => E t
ex = E _x


-- Instances
-- ---------

pattern V1_ :: Elt a => Exp a -> Exp (V1 a)
pattern V1_ x = Pattern x
{-# COMPLETE V1_ #-}

instance Metric V1
instance Additive V1
instance R1 V1
instance Elt a => Elt (V1 a)

instance (Lift Exp a, Elt (Plain a)) => Lift Exp (V1 a) where
  type Plain (V1 a) = V1 (Plain a)
  lift (V1 x) = V1_ (lift x)

instance Elt a => Unlift Exp (V1 (Exp a)) where
  unlift (V1_ x) = V1 x

instance (Elt a, Elt b) => Each (Exp (V1 a)) (Exp (V1 b)) (Exp a) (Exp b) where
  each = liftLens (each :: Traversal (V1 (Exp a)) (V1 (Exp b)) (Exp a) (Exp b))

instance A.Eq a => A.Eq (V1 a) where
  V1_ x == V1_ y = x A.== y
  V1_ x /= V1_ y = x A./= y

instance A.Ord a => A.Ord (V1 a) where
  V1_ x <  V1_ y = x A.< y
  V1_ x >  V1_ y = x A.> y
  V1_ x >= V1_ y = x A.>= y
  V1_ x <= V1_ y = x A.<= y
  min (V1_ x) (V1_ y) = V1_ (A.min x y)
  max (V1_ x) (V1_ y) = V1_ (A.max x y)

instance A.Bounded a => P.Bounded (Exp (V1 a)) where
  minBound = V1_ minBound
  maxBound = V1_ maxBound

instance A.Num a => P.Num (Exp (V1 a)) where
  (+)             = lift2 ((+) :: V1 (Exp a) -> V1 (Exp a) -> V1 (Exp a))
  (-)             = lift2 ((-) :: V1 (Exp a) -> V1 (Exp a) -> V1 (Exp a))
  (*)             = lift2 ((*) :: V1 (Exp a) -> V1 (Exp a) -> V1 (Exp a))
  negate          = lift1 (negate :: V1 (Exp a) -> V1 (Exp a))
  signum          = lift1 (signum :: V1 (Exp a) -> V1 (Exp a))
  abs             = lift1 (abs :: V1 (Exp a) -> V1 (Exp a))
  fromInteger x   = V1_ (P.fromInteger x)

instance A.Floating a => P.Fractional (Exp (V1 a)) where
  (/)             = lift2 ((/) :: V1 (Exp a) -> V1 (Exp a) -> V1 (Exp a))
  recip           = lift1 (recip :: V1 (Exp a) -> V1 (Exp a))
  fromRational x  = V1_ (P.fromRational x)

instance A.Floating a => P.Floating (Exp (V1 a)) where
  pi              = V1_ pi
  log             = lift1 (log :: V1 (Exp a) -> V1 (Exp a))
  exp             = lift1 (exp :: V1 (Exp a) -> V1 (Exp a))
  sin             = lift1 (sin :: V1 (Exp a) -> V1 (Exp a))
  cos             = lift1 (cos :: V1 (Exp a) -> V1 (Exp a))
  tan             = lift1 (tan :: V1 (Exp a) -> V1 (Exp a))
  sinh            = lift1 (sinh :: V1 (Exp a) -> V1 (Exp a))
  cosh            = lift1 (cosh :: V1 (Exp a) -> V1 (Exp a))
  tanh            = lift1 (tanh :: V1 (Exp a) -> V1 (Exp a))
  asin            = lift1 (asin :: V1 (Exp a) -> V1 (Exp a))
  acos            = lift1 (acos :: V1 (Exp a) -> V1 (Exp a))
  atan            = lift1 (atan :: V1 (Exp a) -> V1 (Exp a))
  asinh           = lift1 (asinh :: V1 (Exp a) -> V1 (Exp a))
  acosh           = lift1 (acosh :: V1 (Exp a) -> V1 (Exp a))
  atanh           = lift1 (atanh :: V1 (Exp a) -> V1 (Exp a))

instance Epsilon a => Epsilon (V1 a) where
  nearZero (V1_ x) = nearZero x

instance A.Functor V1 where
  fmap f (V1_ x) = V1_ (f x)
  x <$ _         = V1_ x

