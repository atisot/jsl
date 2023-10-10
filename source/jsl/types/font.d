module jsl.types.font;

import jsl;

import std.string;
import std.array;
import std.range;

struct FontFamily
{
    string[] fonts;
    string type;

    static FontFamily parse(string input)
    {
        FontFamily result;

        // Разбиваем строку по запятой
        auto parts = input.split(",").array;

        foreach (key, part; parts)
        {
            parts[key] = part.strip;
        }

        result.type = parts[$-1];

        parts = parts[0 .. $-1];

        result.fonts = parts;

        return result;
    }
}
