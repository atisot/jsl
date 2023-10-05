module jsonstyling.utils;

import std.algorithm;
import std.range;
import std.format;
import std.string;
import std.traits;
import std.ascii;
import std.conv;

import jsonstyling.types;

enum props = cast(string[])
[
    "width"                         , Dimension.stringof,
    "height"                        , Dimension.stringof,
    "min-width"                     , Dimension.stringof,
    "max-width"                     , Dimension.stringof,
    "min-height"                    , Dimension.stringof,
    "max-height"                    , Dimension.stringof,
    "margin"                        , Dimension.stringof,
    "margin-top"                    , Dimension.stringof,
    "margin-right"                  , Dimension.stringof,
    "margin-bottom"                 , Dimension.stringof,
    "margin-left"                   , Dimension.stringof,
    "padding"                       , Dimension.stringof,
    "padding-top"                   , Dimension.stringof,
    "padding-right"                 , Dimension.stringof,
    "padding-bottom"                , Dimension.stringof,
    "padding-left"                  , Dimension.stringof,
    "background-color"              , Color.stringof,
    "background-image"              , string.stringof,
    "border"                        , Border.stringof,
    "border-color"                  , Color.stringof,
    "border-width"                  , Dimension.stringof,
    "border-style"                  , BorderStyle.stringof,
    "border-top"                    , Border.stringof,
    "border-right"                  , Border.stringof,
    "border-bottom"                 , Border.stringof,
    "border-left"                   , Border.stringof,
    "border-radius"                 , BorderRadius.stringof,
    "border-top-left-radius"        , BorderRadius.stringof,
    "border-top-right-radius"       , BorderRadius.stringof,
    "border-bottom-right-radius"    , BorderRadius.stringof,
    "border-bottom-left-radius"     , BorderRadius.stringof,
    "opacity"                       , float.stringof,
    "display"                       , Display.stringof,
    "position"                      , Position.stringof,
    "vertical-align"                , VAlign.stringof,
    "horizontal-align"              , HAlign.stringof,
    "transform"                     , string.stringof,
    "box-shadow"                    , BoxShadow.stringof,
    "color"                         , Color.stringof,
    "font-family"                   , string.stringof,
    "font-size"                     , Dimension.stringof,
    "font-weight"                   , FontWeight.stringof,
    "font-style"                    , FontStyle.stringof,
    "text-align"                    , TextAlign.stringof,
    "cursor"                        , Cursor.stringof
];

bool canFindProperty(string value)
{
    for (size_t i = 0; i < props.length-1; i += 2)
    {
        if (props[i] == value)
        {
            return true;
        }
    }
    return false;
}

template addProperties(string[] props, classType)
{
    const dchar[] addProperties = props
        .chunks(2)
        .map!(p => propertyGenerator!(classType)(p[0], p[1]))
        .joiner("\n")
        .array;
}

auto propertyGenerator(alias classType)(string name, string type)
{
    return format(
        `
           %4$s %2$s(%1$s value)
           {
               style.property("%3$s", value);
               return this;
           }
        `,
        type, toMemberName(name), name, classType.stringof
    );
}

string toMemberName(string name)
{
    // Преобразует имя в формат camelCase

    string result;

    auto parts = name.split("-");
    foreach (idx, part; parts)
    {
        if (idx == 0)
            result ~= toLower(part);
        else
            result ~= std.ascii.toUpper(part[0]) ~ part[1 .. $].toLower;
    }

    return result;
}

float toPixels(Dimension dim, float relativeValue = 1.0)
{
    switch (dim.unit)
    {
    case Unit.CM:
        return dim.value * 96 / 2.54;

    case Unit.MM:
        return dim.value * 96 / 25.4;

    case Unit.INCH:
        return dim.value * 96;

    case Unit.PT:
        return dim.value * 96 / 72;

    case Unit.PC:
        return dim.value * 12 * 96 / 72;

    case Unit.EM:
        return dim.value * relativeValue;

    case Unit.REM:
        return dim.value * relativeValue;

    case Unit.VW:
    case Unit.VH:
    case Unit.VMIN:
    case Unit.VMAX:
    case Unit.PERCENT:
        return dim.value * relativeValue / 100.0f;

    case Unit.PX:
    default:
        return dim.value;
    }
}

string color2string(Color color)
{
    if (color.a == 0xFF) // Если альфа-канал полностью прозрачен
    {
        return format("#%02X%02X%02X", color.r, color.g, color.b);
    }
    else
    {
        return format("#%02X%02X%02X%02X", color.r, color.g, color.b, color.a);
    }
}

Color hslToRgb(float h, float s, float l, ubyte a = 255)
{
    float r, g, b;

    if (s == 0)
    {
        r = g = b = l; // achromatic
    }
    else
    {
        float hue2rgb(float p, float q, float t)
        {
            if (t < 0)
                t += 1;
            if (t > 1)
                t -= 1;
            if (t < 1.0 / 6.0)
                return p + (q - p) * 6.0 * t;
            if (t < 1.0 / 2.0)
                return q;
            if (t < 2.0 / 3.0)
                return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
            return p;
        }

        float q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        float p = 2 * l - q;
        h /= 360.0;
        r = hue2rgb(p, q, h + 1.0 / 3.0);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1.0 / 3.0);
    }

    return Color(to!ubyte(r * 255), to!ubyte(g * 255), to!ubyte(b * 255), a);
}