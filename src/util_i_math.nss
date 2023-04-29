/// ----------------------------------------------------------------------------
/// @file   util_i_math.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Useful math utility functions.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Return the closest integer to the binary logarithm of a number.
int log2(int n);

/// @brief Restrict an integer to a range.
/// @param nValue The number to evaluate.
/// @param nMin The minimum value for the number.
/// @param nMax The maximum value for the number.
/// @returns nValue if it is between nMin and nMax. Otherwise returns the
///     closest of nMin or nMax.
int clamp(int nValue, int nMin, int nMax);

/// @brief Restrict a float to a range.
/// @param fValue The number to evaluate.
/// @param fMin The minimum value for the number.
/// @param fMax The maximum value for the number.
/// @returns fValue if it is between fMin and fMax. Otherwise returns the
///     closest of fMin or fMax.
float fclamp(float fValue, float fMin, float fMax);

/// @brief Return the larger of two integers.
int max(int a, int b);

/// @brief Return the smaller of two integers.
int min(int a, int b);

/// @brief Return the sign of an integer.
/// @returns -1 if n is negative, 0 if 0, or 1 if positive.
int sign(int n);

/// @brief Return the larger of two floats.
float fmax(float a, float b);

/// @brief Return the smaller of two floats.
float fmin(float a, float b);

/// @brief Return the sign of a float.
/// @returns -1 if f is negative, 0 if 0, or 1 if positive.
int fsign(float f);

/// @brief Truncate a float (i.e., remove numbers to the right of the decimal
///     point).
float trunc(float f);

/// @brief Return the fractional part of a float (i.e., numbers to the right of
///     the decimal point).
float frac(float f);

/// @brief Return a % b (modulo function).
/// @param a The dividend
/// @param b The divisor
/// @note For consistency with NWN's integer modulo operator, the result has the
///     same sign as a (i.e., fmod(-1, 2) == -1).
float fmod(float a, float b);

/// @brief Round a float down to the nearest whole number.
float floor(float f);

/// @brief Round a float up to the nearest whole number.
float ceil(float f);

/// @brief Round a float towards to the nearest whole number.
/// @note In case of a tie (i.e., +/- 0.5), rounds away from 0.
float round(float f);

/// @brief Determine if x is in [a..b]
/// @param x Value to compare
/// @param a Low end of range
/// @param b High end of range
int between(int x, int a, int b);

/// @brief Determine if x is in [a..b]
/// @param x Value to compare
/// @param a Low end of range
/// @param b High end of range
int fbetween(float x, float a, float b);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

int log2(int n)
{
    int nResult;
    while (n >>= 1)
        nResult++;
    return nResult;
}

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

int between(int x, int a, int b)
{
    return ((x - a) * (x - b)) <= 0;
}

int fbetween(float x, float a, float b)
{
    return ((x - a) * (x - b)) <= 0.0;
}
