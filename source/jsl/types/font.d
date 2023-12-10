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
        if(input.empty)
            throw new Exception("FontFamily input line is empty");
        
        FontFamily result;

        auto parts = input.split(",").array;

        foreach (key, part; parts)
        {
            parts[key] = part.strip;
        }

        if(parts.length > 1)
        {
            result.type = parts[$ - 1];
            parts = parts[0 .. $ - 1];
            result.fonts = parts;
        }
        else 
        {
            result.fonts ~= parts[0].strip;
            result.type = "sans-serif";
        }

        return result;
    }
}
