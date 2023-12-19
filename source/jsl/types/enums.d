module jsl.types.enums;

import jsl.utils;

mixin(generateEnumProperties!(props));
//pragma(msg, generateEnumProperties!(props));

enum VAlign
{
    TOP,
    BOTTOM
}

enum HAlign
{
    LEFT,
    RIGHT
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
    NOT_ALLOWED,
    CUSTOM
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