// SPDX-License-Identifier: GPL-2.0
/// Find function arguments that can be declared const. Confidence in the
/// results in low for now, but the compiler should catch any incorrect const
/// qualifier.
// Confidence: Low
// Copyright (C) 2020 Authors of Cilium.
// Comments:
// Options: --include-headers
@ rule1 @
identifier f, fn, x, z;
type T0, T;
@@

(
  // Match this case first to avoid duplicating const qualifier.
  T0 fn (..., const T *x, ...) { ... }
|
  // Match this case first to avoid marking __maybe_unused parameters as const.
  T0 fn (..., T *x, ...) {
  ... when != x
  }
|
  T0 fn (...,
- T *x
+ const T *x
  , ...)
  {
  // Avoid matching any function where x's value is assigned or x is passed to
  // another function.
  ... when != *x = ...
      when != x->z = ...
      when != x->z &= ...
      when != x->z += ...
      when != x->z -= ...
      when != x->z |= ...
      when != x->z *= ...
      when != x->z /= ...
      when != x->z[...] = ...
      when != f(..., x, ...)
      when != f(..., &x->z, ...)
  }
)
