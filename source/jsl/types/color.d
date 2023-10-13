module jsl.types.color;

import jsl.types;
import jsl.exceptions;

import std.traits;
import std.algorithm;
import std.string;
import std.math;

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


struct Color
{
    version (RAYLIB)
    {
        import bindbc.raylib.types;

        bindbc.raylib.types.Color color;
        alias color this;

        this(ubyte r, ubyte g, ubyte b, ubyte a = 255)
        {
            color.r = r;
            color.g = g;
            color.b = b;
            color.a = a;
        }


        void r(ubyte value) @property
        {
            color.r = value;
        }

        auto r() @property const
        {
            return color.r;
        }

        void g(ubyte value) @property
        {
            color.g = value;
        }

        auto g() @property const
        {
            return color.g;
        }

        void b(ubyte value) @property
        {
            color.b = value;
        }

        auto b() @property const
        {
            return color.b;
        }

        void a(ubyte value) @property
        {
            color.a = value;
        }

        auto a() @property const
        {
            return color.a;
        }
    }
    else
    {
        /// Color red value
        ubyte r;
        /// Color green value
        ubyte g;
        /// Color blue value
        ubyte b;
        /// Color alpha value
        ubyte a;

        this(ubyte r, ubyte g, ubyte b, ubyte a = 255)
        {
            this.r = r;
            this.g = g;
            this.b = b;
            this.a = a;
        }
    }

    static Color parse(string input)
    {
        if ([EnumMembers!Colors].canFind!(a => to!string(a) == input.toUpper))
        {
            return input.toUpper.to!Colors;
        }

        // По умолчанию альфа-канал равен 255 (непрозрачный)
        ubyte defaultAlpha = 255;

        // Регулярные выражения для различных форматов
        auto hexPattern = regex(`^#([0-9a-fA-F]{3,8})$`);
        auto rgbPattern = regex(`^rgb\((\d+),\s*(\d+),\s*(\d+)\)$`);
        auto rgbaPattern = regex(`^rgba\((\d+),\s*(\d+),\s*(\d+),\s*(\d*(?:\.\d+)?)\)$`);
        auto hslPattern = regex(`^hsl\((\d+),\s*(\d+)%,\s*(\d+)%\)$`);
        auto hslaPattern = regex(`^hsla\((\d+),\s*(\d+)%,\s*(\d+)%,\s*(\d*(?:\.\d+)?)\)$`);

        // Проверка на соответствие
        if (matchFirst(input, hexPattern))
        {
            auto hexMatch = matchFirst(input, hexPattern);
            uint hexValue = to!uint(hexMatch[1], 16); // Преобразование всей строки в целое число

            switch (hexMatch[1].length)
            {
            case 3:
                return Color(
                    (hexValue >> 8 & 0xF) | (hexValue >> 4 & 0xF0),
                    (hexValue >> 4 & 0xF) | (hexValue & 0xF0),
                    (hexValue & 0xF) | (hexValue << 4 & 0xF0),
                    defaultAlpha
                );
            case 6:
                return Color(
                    (hexValue >> 16) & 0xFF,
                    (hexValue >> 8) & 0xFF,
                    hexValue & 0xFF,
                    defaultAlpha
                );
            case 8:
                return Color(
                    (hexValue >> 24) & 0xFF,
                    (hexValue >> 16) & 0xFF,
                    (hexValue >> 8) & 0xFF,
                    hexValue & 0xFF
                );
            default:
                throw new ThemeParseException("Invalid hex color format: " ~ input);
            }
        }
        else if (matchFirst(input, rgbPattern))
        {
            auto rgbMatch = matchFirst(input, rgbPattern);
            return Color(to!ubyte(rgbMatch[1]),
                to!ubyte(rgbMatch[2]),
                to!ubyte(rgbMatch[3]),
                defaultAlpha
            );
        }
        else if (matchFirst(input, rgbaPattern))
        {
            auto rgbaMatch = matchFirst(input, rgbaPattern);
            return Color(to!ubyte(rgbaMatch[1]),
                to!ubyte(rgbaMatch[2]),
                to!ubyte(rgbaMatch[3]),
                to!ubyte(round(to!float(rgbaMatch[4]) * 255))
            );
        }
        else if (matchFirst(input, hslPattern))
        {
            auto hslMatch = matchFirst(input, hslPattern);
            return hslToRgb(to!float(hslMatch[1]),
                to!float(hslMatch[2]) / 100.0,
                to!float(hslMatch[3]) / 100.0
            );
        }
        else if (matchFirst(input, hslaPattern))
        {
            auto hslaMatch = matchFirst(input, hslaPattern);
            return hslToRgb(to!float(hslaMatch[1]),
                to!float(hslaMatch[2]) / 100.0,
                to!float(hslaMatch[3]) / 100.0,
                to!ubyte(round(to!float(hslaMatch[4]) * 255))
            );
        }
        
        throw new ThemeParseException("Invalid hex color format: " ~ input);
    }

    unittest
    {
        // Hex
        assert(parse("#F00") == Color(255, 0, 0, 255));
        assert(parse("#FF0000") == Color(255, 0, 0, 255));
        assert(parse("#FF000080") == Color(255, 0, 0, 128));

        // RGB
        assert(parse("rgb(255, 0, 0)") == Color(255, 0, 0, 255));

        // RGBA
        assert(parse("rgba(255, 0, 0, 0.5)") == Color(255, 0, 0, 128));

        // HSL
        assert(parse("hsl(0, 100%, 50%)") == Color(255, 0, 0, 255));
        assert(parse("hsl(120, 100%, 50%)") == Color(0, 255, 0, 255));
        assert(parse("hsl(240, 100%, 50%)") == Color(0, 0, 255, 255));

        // HSLA
        assert(parse("hsla(0, 100%, 50%, 0.5)") == Color(255, 0, 0, 128));
        assert(parse("hsla(120, 100%, 50%, 0.5)") == Color(0, 255, 0, 128));
        assert(parse("hsla(240, 100%, 50%, 0.5)") == Color(0, 0, 255, 128));

        // string
        assert(parse("green") == Color(0, 255, 0, 255));
        assert(parse("seashell") == Color(255, 245, 238, 255));

        //TODO: отрицательные тесты
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