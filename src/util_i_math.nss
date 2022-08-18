// -----------------------------------------------------------------------------
//    File: util_i_math.nss
//  System: Utilities
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file contains useful math utility functions. Note than some of the float
// functions (notably fmod) may be slightly off (+/- a millionth) due to the
// nature of floating point arithmetic.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< clamp >---
// ---< util_i_math >---
// If nValue is less than nMin, returns nMin. If nValue is greater than nMax,
// returns nMax. Otherwise, returns nValue.
int clamp(int nValue, int nMin, int nMax);

// ---< fclamp >---
// ---< util_i_math >---
// If fValue is less than fMin, returns fMin. If fValue is greater than fMax,
// returns fMax. Otherwise, returns fValue.
float fclamp(float fValue, float fMin, float fMax);

// ---< max >---
// ---< util_i_math >---
// Returns the larger of two integers.
int max(int a, int b);

// ---< min >---
// ---< util_i_math >---
// Returns the smaller of two integers
int min(int a, int b);

// ---< sign >---
// ---< util_i_math >---
// Returns the sign of an integer (i.e., returns -1 if negative, 0 if 0, or 1 if
// positive).
int sign(int n);

// ---< fmax >---
// ---< util_i_math >---
// Returns the larger of two floats.
float fmax(float a, float b);

// ---< fmin >---
// ---< util_i_math >---
// Returns the smaller of two floats.
float fmin(float a, float b);

// ---< fsign >---
// ---< util_i_math >---
// Returns the sign of a float (i.e., returns -1 if negative, 0 if 0, or 1 if
// positive).
int fsign(float f);

// ---< trunc >---
// ---< util_i_math >---
// Returns f with any fractional part removed.
float trunc(float f);

// ---< frac >---
// ---< util_i_math >---
// Returns the fractional part of f (i.e., the numbers to the right of the
// decimal point).
float frac(float f);

// ---< fmod >---
// ---< util_i_math >---
// Returns a % b (modulo function). For consistency with NWN's integer modulo
// operator, the result has the same sign as a (i.e., fmod(-1, 2) == -1).
float fmod(float a, float b);

// ---< floor >---
// ---< util_i_math >---
// Returns f rounded down to the nearest whole number.
float floor(float f);

// ---< ceil >---
// ---< util_i_math >---
// Returns f rounded up to the nearest whole number.
float ceil(float f);

// ---< round >---
// ---< util_i_math >---
// Returns f rounded towards to the nearest whole number. In case of a tie
// (i.e., +/- 0.5), rounds away from 0.
float round(float f);


// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

int clamp(int nValue, int nMin, int nMax)
{
    return (nValue < nMin) ? nMin : ((nValue > nMax) ? nMax : nValue);
}

float fclamp(float fValue, float fMin, float fMax)
{
    return (fValue < fMin) ? fMin : ((fValue > fMax) ? fMax : fValue);
}

int max(int a, int b)
{
    return (b > a) ? b : a;
}

int min(int a, int b)
{
    return (b > a) ? a : b;
}

int sign(int n)
{
    return (n > 0) ? 1 : (n < 0) ? -1 : 0;
}

float fmax(float a, float b)
{
    return (b > a) ? b : a;
}

float fmin(float a, float b)
{
    return (b > a) ? a : b;
}

int fsign(float f)
{
    return f > 0.0 ? 1 : f < 0.0 ? -1 : 0;
}

float trunc(float f)
{
    return IntToFloat(FloatToInt(f));
}

float frac(float f)
{
    return f - trunc(f);
}

float fmod(float a, float b)
{
    return a - b * trunc(a / b);
}

float floor(float f)
{
    return IntToFloat(FloatToInt(f) - (f < 0.0));
}

float ceil(float f)
{
    return IntToFloat(FloatToInt(f) + (trunc(f) < f));
}

float round(float f)
{
    return IntToFloat(FloatToInt(f + (f < 0.0 ? -0.5 : 0.5)));
}
