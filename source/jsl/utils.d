module jsl.utils;

/**
 * Module for JSON styling utilities.
 */

import std.algorithm;
import std.range;
import std.format;
import std.string;
import std.traits;
import std.ascii;
import std.conv;

import jsl;

/**
 * A list of supported style properties and their corresponding types.
 */
enum props = cast(string[])
[
    "width"                         , Dimension.stringof,
    "height"                        , Dimension.stringof,
    "min-width"                     , Dimension.stringof,
    "max-width"                     , Dimension.stringof,
    "min-height"                    , Dimension.stringof,
    "max-height"                    , Dimension.stringof,
    "margin"                        , Dimensions.stringof,
    "padding"                       , Dimensions.stringof,
    "border"                        , Border.stringof,
    "border-radius"                 , BorderRadius.stringof,
    "background-color"              , Color.stringof,
    "background-gradient"           , Gradient.stringof,
    "background-image"              , string.stringof,
    "opacity"                       , float.stringof,
    "visible"                       , bool.stringof,
    "display"                       , bool.stringof,
    "vertical-align"                , VAlign.stringof,
    "horizontal-align"              , HAlign.stringof,
    "box-shadow"                    , BoxShadow.stringof,
    "text-color"                    , Color.stringof,
    "font-id"                       , string.stringof,
    "font-size"                     , Dimension.stringof,
    "font-weight"                   , FontWeight.stringof,
    "font-style"                    , FontStyle.stringof,
    "text-align"                    , TextAlign.stringof,
    "cursor"                        , Cursor.stringof
];

string propertyType(string propName)
{
    for (size_t i = 0; i < props.length - 1; i += 2)
    {
        if (props[i] == propName)
        {
            return props[i+1];
        }
    }

    throw new JSLException("Unknown property: " ~ propName);
}

/**
 * Checks if the given property name exists in the supported properties list.
 *
 * Params:
 *   value = The property name to check.
 *
 * Returns:
 *   `true` if the property exists, `false` otherwise.
 */
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

template generateEnumProperties(string[] props)
{
    const dchar[] generateEnumProperties = "enum StyleProperty : string {\n" ~ props
        .chunks(2)
        .map!(p => kebab2camel(p[0]) ~ " = \"" ~ p[0] ~ "\",")
        .joiner("\n")
        .array[0..$-1] ~ "\n}";
}

/**
 * Generates methods for setting style properties based on the provided properties list.
 *
 * Params:
 *   props = The properties list.
 *   classType = The type of the class where the methods will be added.
 */
template addProperties(string[] props, classType)
{
    const dchar[] addProperties = props
        .chunks(2)
        .map!(p => propertyGenerator!(classType)(p[0], p[1]))
        .joiner("\n")
        .array;
}

/**
 * Generates a method for setting a specific style property.
 *
 * Params:
 *   name = The property name.
 *   type = The type of the property.
 *
 * Returns:
 *   A string containing the generated method.
 */
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
        type, kebab2camel(name), name, classType.stringof
    );
}

/**
 * Converts a property name from kebab-case to camelCase.
 *
 * Params:
 *   name = The property name in kebab-case.
 *
 * Returns:
 *   The property name in camelCase.
 */
string kebab2camel(string name)
{
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

/**
 * Converts a `Dimension` value to pixels.
 *
 * Params:
 *   dim = The `Dimension` value to convert.
 *   relativeValue = A relative value used for units like `EM`, `REM`, etc.
 *
 * Returns:
 *   The converted value in pixels.
 */
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

/**
 * Checks if a type is an enumeration.
 *
 * Params:
 *   T = The type to check.
 *
 * Returns:
 *   `true` if the type is an enumeration, `false` otherwise.
 */
template isEnum(T)
{
    static if (is(T == enum))
        enum bool isEnum = true;
    else
        enum bool isEnum = false;
}

/**
 * Checks if a type is a simple type.
 * Simple types include string, bool, and numeric types.
 *
 * Params:
 *   T = The type to check.
 *
 * Returns:
 *   `true` if the type is a simple type, `false` otherwise.
 */
template isSimpleType(T)
{
    enum bool isSimpleType = !isEnum!T && (is(T == string) || is(T == bool) || std
                .traits.isNumeric!T);
}