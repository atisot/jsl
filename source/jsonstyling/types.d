module jsonstyling.types;

import std.meta;
import std.traits;
import std.typecons;

enum VAlign
{
    top,
    bottom
}

enum HAlign
{
    left,
    right
}

struct Dimension
{
    float value;
    Unit unit;
}

struct Border
{
    Dimension width;
    Color color;
    BorderStyle style;
}

struct BorderRadius
{
    Dimension horizontal;
    Dimension vertical;
}

struct BoxShadow
{
    Dimension offsetX;
    Dimension offsetY;
    Dimension blurRadius;
    Dimension spreadRadius;
    Color color;
}

struct Color
{
    /// Color red value
    ubyte r;
    /// Color green value
    ubyte g;
    /// Color blue value
    ubyte b;
    /// Color alpha value
    ubyte a;
}

enum Colors : Color
{
    TRANSPARENT = Color(0, 0, 0, 0),
    BLACK = Color(0, 0, 0, 255),
    WHITE = Color(255, 255, 255, 255),
    RED = Color(255, 0, 0, 255),
    GREEN = Color(0, 255, 0, 255),
    BLUE = Color(0, 0, 255, 255),
    YELLOW = Color(255, 255, 0, 255),
    CYAN = Color(0, 255, 255, 255),
    MAGENTA = Color(255, 0, 255, 255),
    GRAY = Color(128, 128, 128, 255),
    LIGHTGRAY = Color(192, 192, 192, 255),
    DARKGRAY = Color(64, 64, 64, 255),
    ORANGE = Color(255, 165, 0, 255),
    PURPLE = Color(128, 0, 128, 255),
    BROWN = Color(165, 42, 42, 255),
    LIME = Color(50, 205, 50, 255),
    OLIVE = Color(128, 128, 0, 255),
    TEAL = Color(0, 128, 128, 255),
    NAVY = Color(0, 0, 128, 255),
    MAROON = Color(128, 0, 0, 255),
    AQUA = Color(0, 255, 255, 255),
    FUCHSIA = Color(255, 0, 255, 255),
    SILVER = Color(192, 192, 192, 255),
    GOLD = Color(255, 215, 0, 255),
    CORAL = Color(255, 127, 80, 255),
    SALMON = Color(250, 128, 114, 255),
    BEIGE = Color(245, 245, 220, 255),
    INDIGO = Color(75, 0, 130, 255),
    VIOLET = Color(238, 130, 238, 255),
    LAVENDER = Color(230, 230, 250, 255),
    KHAKI = Color(240, 230, 140, 255),
    TAN = Color(210, 180, 140, 255),
    TURQUOISE = Color(64, 224, 208, 255),
    PINK = Color(255, 192, 203, 255),
    SLATEBLUE = Color(106, 90, 205, 255),
    FORESTGREEN = Color(34, 139, 34, 255),
    CRIMSON = Color(220, 20, 60, 255),
    CHOCOLATE = Color(210, 105, 30, 255),
    TOMATO = Color(255, 99, 71, 255),
    SPRINGGREEN = Color(0, 255, 127, 255),
    STEELBLUE = Color(70, 130, 180, 255),
    PLUM = Color(221, 160, 221, 255),
    PERIWINKLE = Color(204, 204, 255, 255),
    ORCHID = Color(218, 112, 214, 255),
    GOLDENROD = Color(218, 165, 32, 255),
    MEDIUMPURPLE = Color(147, 112, 219, 255),
    MEDIUMSEAGREEN = Color(60, 179, 113, 255),
    SIENNA = Color(160, 82, 45, 255),
    SKYBLUE = Color(135, 206, 235, 255),
    MIDNIGHTBLUE = Color(25, 25, 112, 255),
    PEACHPUFF = Color(255, 218, 185, 255),
    FIREBRICK = Color(178, 34, 34, 255),
    HONEYDEW = Color(240, 255, 240, 255),
    DEEPSKYBLUE = Color(0, 191, 255, 255),
    MISTYROSE = Color(255, 228, 225, 255),
    CADETBLUE = Color(95, 158, 160, 255),
    LEMONCHIFFON = Color(255, 250, 205, 255),
    DARKORCHID = Color(153, 50, 204, 255),
    PALEGOLDENROD = Color(238, 232, 170, 255),
    CORNFLOWERBLUE = Color(100, 149, 237, 255),
    SEASHELL = Color(255, 245, 238, 255),
    DARKGOLDENROD = Color(184, 134, 11, 255),
    LIGHTCORAL = Color(240, 128, 128, 255),
    ROSYBROWN = Color(188, 143, 143, 255),
    PALETURQUOISE = Color(175, 238, 238, 255)
}

enum Unit : string
{
    PX = "px",
    CM = "cm",
    MM = "mm",
    INCH = "in",
    PT = "pt",
    PC = "pc",
    EM = "em",
    REM = "rem",
    EX = "ex",
    CH = "ch",
    VW = "vw",
    VH = "vh",
    VMIN = "vmin",
    VMAX = "vmax",
    PERCENT = "%"
}

enum BorderStyle
{
    NONE,
    SOLID,
    DASHED,
    DOTTED
}

enum Display
{
    NONE,
    BLOCK,
    INLINE,
    FLEX,
    GRID
}

enum Position
{
    STATIC,
    RELATIVE,
    ABSOLUTE,
    FIXED,
    STICKY
}

enum TextAlign
{
    LEFT,
    RIGHT,
    CENTER,
    JUSTIFY
}

enum Cursor
{
    DEFAULT,
    POINTER,
    TEXT,
    WAIT,
    CROSSHAIR,
    NOT_ALLOWED
}

enum FontStyle
{
    NORMAL,
    ITALIC,
    OBLIQUE
}

enum FontWeight
{
    NORMAL,
    BOLD,
    BOLDER,
    LIGHTER
}