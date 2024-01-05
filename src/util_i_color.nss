/// ----------------------------------------------------------------------------
/// @file   util_i_color.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Functions to handle colors.
/// @details
/// NWN normally uses color codes to color strings. These codes take the format
/// `<cRGB>`, where RGB are ALT codes (0-0255) for colors.
///
/// Because color codes are arcane and can't be easily looked up, the functions
/// in this file prefer to use hex color codes. These codes are the same as
/// you'd use in web design and many other areas, so they are easy to look up
/// and can be copied and pasted into other programs. util_c_color.nss provides
/// some hex codes for common uses.
///
/// This file also contains functions to represent colors as RGB or HSV
/// triplets. HSV (Hue, Saturation, Value) may be particularly useful if you
/// want to play around with shifting colors.
///
/// ## Acknowledgements
/// - `GetColorCode()` function by rdjparadis.
/// - RGB <-> HSV colors adapted from NWShacker's Named Color Token System.
/// ----------------------------------------------------------------------------

#include "x3_inc_string"
#include "util_i_math"
#include "util_c_color"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

/// Used to generate colors from RGB values. NEVER modify this string.
/// @see https://nwn.wiki/display/NWN1/Colour+Tokens
/// @note First character is "nearest to 00" since we can't use `\x00` itself
/// @note COLOR_TOKEN originally by rdjparadis. Converted to NWN:EE escaped
///     characters by Jasperre.
const string COLOR_TOKEN = "\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2A\x2B\x2C\x2D\x2E\x2F\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3A\x3B\x3C\x3D\x3E\x3F\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4A\x4B\x4C\x4D\x4E\x4F\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5A\x5B\x5C\x5D\x5E\x5F\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6A\x6B\x6C\x6D\x6E\x6F\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7A\x7B\x7C\x7D\x7E\x7F\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF";

// -----------------------------------------------------------------------------
//                                     Types
// -----------------------------------------------------------------------------

struct RGB
{
    int r;
    int g;
    int b;
};

struct HSV
{
    float h;
    float s;
    float v;
};

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ----- Type Creation ---------------------------------------------------------

/// @brief Create an RBG color struct.
/// @param nRed The value of the red channel (0..255).
/// @param nGreen The value of the green channel (0..255).
/// @param nBlue The value of the blue channel (0..255).
struct RGB GetRGB(int nRed, int nGreen, int nBlue);

/// @brief Create an HSV color struct.
/// @details The ranges are as follows:
///     0.0 <= H < 360.0
///     0.0 <= S <= 1.0
///     0.0 <= V <= 1.0
/// @param fHue The hue (i.e. location on color wheel).
/// @param fSaturation The saturation (i.e., distance from white/black).
/// @param fValue The value (i.e., brightness of color).
struct HSV GetHSV(float fHue, float fSaturation, float fValue);

// ----- Type Conversion -------------------------------------------------------

/// @brief Convert a hexadecimal color to an RGB struct.
/// @param nColor Hexadecimal to convert to RGB.
struct RGB HexToRGB(int nColor);

/// @brief Convert an RGB struct to a hexadecimal color.
/// @param rgb RGB to convert to hexadecimal.
int RGBToHex(struct RGB rgb);

/// @brief Convert an RGB struct to an HSV struct.
/// @param rgb RGB to convert to HSV.
struct HSV RGBToHSV(struct RGB rgb);

/// @brief Convert an HSV struct to an RGB struct.
/// @param hsv HSV to convert to RGB.
struct RGB HSVToRGB(struct HSV hsv);

/// @brief Converts a hexadecimal color to an HSV struct.
/// @param nColor Hexadecimal to convert to HSV.
struct HSV HexToHSV(int nColor);

/// @brief Converts an HSV struct to a hexadecial color.
/// @param hsv HSV to convert to hexadecimal.
int HSVToHex(struct HSV hsv);

// ----- Coloring Functions ----------------------------------------------------

/// @brief Construct a color code that can be used to color a string.
/// @param nRed The intensity of the red channel (0..255).
/// @param nGreen The intensity of the green channel (0..255).
/// @param nBlue The intensity of the blue channel (0..255).
/// @returns A string color code in `<cRBG>` form.
string GetColorCode(int nRed, int nGreen, int nBlue);

/// @brief Convert a hexadecimal color to a color code.
/// @param nColor Hexadecimal representation of an RGB color.
/// @returns A string color code in `<cRBG>` form.
string HexToColor(int nColor);

/// @brief Convert a color code prefix to a hexadecimal
/// @param sColor A string color code in `<cRBG>` form.
int ColorToHex(string sColor);

/// @brief Color a string with a color code.
/// @param sString The string to color.
/// @param sColor A string color code in `<cRBG>` form.
string ColorString(string sString, string sColor);

/// @brief Color a string with a hexadecimal color.
/// @param sString The string to color.
/// @param nColor A hexadecimal color.
string HexColorString(string sString, int nColor);

/// @brief Color a string with an RGB color.
/// @param sString The string to color.
/// @param rgb The RGB color struct.
string RGBColorString(string sString, struct RGB rgb);

/// @brief Color a string with a struct HSV color
/// @param sString The string to color.
/// @param hsv The HSV color struct.
string HSVColorString(string sString, struct HSV hsv);

/// @brief Remove color codes from a string.
/// @param sString The string to uncolor.
/// @returns sString with color codes removed.
string UnColorString(string sString);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Type Creation ---------------------------------------------------------

struct RGB GetRGB(int nRed, int nGreen, int nBlue)
{
    struct RGB rgb;

    rgb.r = clamp(nRed,   0, 255);
    rgb.g = clamp(nGreen, 0, 255);
    rgb.b = clamp(nBlue,  0, 255);

    return rgb;
}

struct HSV GetHSV(float fHue, float fSat, float fVal)
{
    struct HSV hsv;

    hsv.h = fclamp(fHue, 0.0, 360.0);
    hsv.s = fclamp(fSat, 0.0,   1.0);
    hsv.v = fclamp(fVal, 0.0,   1.0);

    if (hsv.h == 360.0)
        hsv.h = 0.0;

    return hsv;
}

// ----- Type Conversion -------------------------------------------------------

struct RGB HexToRGB(int nColor)
{
    int nRed   = (nColor & 0xff0000) >> 16;
    int nGreen = (nColor & 0x00ff00) >> 8;
    int nBlue  = (nColor & 0x0000ff);
    return GetRGB(nRed, nGreen, nBlue);
}

int RGBToHex(struct RGB rgb)
{
    int nRed   = (clamp(rgb.r, 0, 255) << 16);
    int nGreen = (clamp(rgb.g, 0, 255) << 8);
    int nBlue  =  clamp(rgb.b, 0, 255);
    return nRed + nGreen + nBlue;
}

struct HSV RGBToHSV(struct RGB rgb)
{
    // Ensure the RGB values are within defined limits
    rgb = GetRGB(rgb.r, rgb.g, rgb.b);

    struct HSV hsv;

    // Convert RGB to a range from 0 - 1
    float fRed   = IntToFloat(rgb.r) / 255.0;
    float fGreen = IntToFloat(rgb.g) / 255.0;
    float fBlue  = IntToFloat(rgb.b) / 255.0;

    float fMax = fmax(fRed, fmax(fGreen, fBlue));
    float fMin = fmin(fRed, fmin(fGreen, fBlue));
    float fChroma = fMax - fMin;

    if (fMax > fMin)
    {
        if (fMax == fRed)
            hsv.h = 60.0 * ((fGreen - fBlue) / fChroma);
        else if (fMax == fGreen)
            hsv.h = 60.0 * ((fBlue - fRed) / fChroma + 2.0);
        else
            hsv.h = 60.0 * ((fRed - fGreen) / fChroma + 4.0);

        if (hsv.h < 0.0)
            hsv.h += 360.0;
    }

    if (fMax > 0.0)
        hsv.s = fChroma / fMax;

    hsv.v = fMax;
    return hsv;
}

struct RGB HSVToRGB(struct HSV hsv)
{
    // Ensure the HSV values are within defined limits
    hsv = GetHSV(hsv.h, hsv.s, hsv.v);

    struct RGB rgb;

    // If value is 0, the resulting color will always be black
    if (hsv.v == 0.0)
        return rgb;

    // If the saturation is 0, the resulting color will be a shade of grey
    if (hsv.s == 0.0)
    {
        // Scale from white to black based on value
        int nValue = FloatToInt(hsv.v * 255.0);
        return GetRGB(nValue, nValue, nValue);
    }

    float h = hsv.h / 60.0;
    float f = frac(h);
    int v = FloatToInt(hsv.v * 255.0);
    int p = FloatToInt(v * (1.0 - hsv.s));
    int q = FloatToInt(v * (1.0 - hsv.s * f));
    int t = FloatToInt(v * (1.0 - hsv.s * (1.0 - f)));
    int i = FloatToInt(h);

    switch (i % 6)
    {
        case 0: rgb = GetRGB(v, t, p); break;
        case 1: rgb = GetRGB(q, v, p); break;
        case 2: rgb = GetRGB(p, v, t); break;
        case 3: rgb = GetRGB(p, q, v); break;
        case 4: rgb = GetRGB(t, p, v); break;
        case 5: rgb = GetRGB(v, p, q); break;
    }

    return rgb;
}

struct HSV HexToHSV(int nColor)
{
    return RGBToHSV(HexToRGB(nColor));
}

int HSVToHex(struct HSV hsv)
{
    return RGBToHex(HSVToRGB(hsv));
}

// ----- Coloring Functions ----------------------------------------------------

string GetColorCode(int nRed, int nGreen, int nBlue)
{
    return "<c" + GetSubString(COLOR_TOKEN, nRed,   1) +
                  GetSubString(COLOR_TOKEN, nGreen, 1) +
                  GetSubString(COLOR_TOKEN, nBlue,  1) + ">";
}

string HexToColor(int nColor)
{
    if (nColor < 0 || nColor > 0xffffff)
        return "";

    int nRed   = (nColor & 0xff0000) >> 16;
    int nGreen = (nColor & 0x00ff00) >> 8;
    int nBlue  = (nColor & 0x0000ff);
    return GetColorCode(nRed, nGreen, nBlue);
}

int ColorToHex(string sColor)
{
    if (sColor == "")
        return -1;

    string sRed   = GetSubString(sColor, 2, 1);
    string sGreen = GetSubString(sColor, 3, 1);
    string sBlue  = GetSubString(sColor, 4, 1);

    int nRed   = FindSubString(COLOR_TOKEN, sRed) << 16;
    int nGreen = FindSubString(COLOR_TOKEN, sGreen) << 8;
    int nBlue  = FindSubString(COLOR_TOKEN, sBlue);

    return nRed + nGreen + nBlue;
}

string ColorString(string sString, string sColor)
{
    if (sColor != "")
        sString = sColor + sString + "</c>";

    return sString;
}

string HexColorString(string sString, int nColor)
{
    string sColor = HexToColor(nColor);
    return ColorString(sString, sColor);
}

string RGBColorString(string sString, struct RGB rgb)
{
    string sColor = GetColorCode(rgb.r, rgb.g, rgb.b);
    return ColorString(sString, sColor);
}

string HSVColorString(string sString, struct HSV hsv)
{
    struct RGB rgb = HSVToRGB(hsv);
    return RGBColorString(sString, rgb);
}

string UnColorString(string sString)
{
    return RegExpReplace("<c[\\S\\s]{3}>|<\\/c>", sString, "");
}
