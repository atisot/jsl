module jsl.types.border;

import jsl.types;
import jsl.exceptions;

import std.typecons;
import std.typetuple;
import std.traits;
import std.string;
import std.algorithm;
import std.array;

struct Border
{
    Dimension width;
    Color color;
    BorderStyle style;

    bool empty()
    {
        return width.value <= 0;
    }

    static Border parse(string input)
    {
        auto components = input.replace(";", "").split();

        BorderStyle st = BorderStyle.NONE;
        Dimension wd = Dimension(0);
        Color cl = Colors.TRANSPARENT;

        foreach (component; components)
        {
            const string[] styles = [EnumMembers!BorderStyle].map!(e => to!string(e)).array;

            if (styles.canFind!(s => s == component.toUpper))
            {
                st = component.toUpper.to!BorderStyle;
            }
            else
            {
                try
                {
                    wd = Dimension.parse(component);
                }
                catch (Exception e)
                {
                    try
                    {
                        cl = Color.parse(component);
                    }
                    catch (Exception e2)
                    {
                        throw new ThemeParseException("Invalid frame property entry format: " ~ input);
                    }
                }
            }
        }

        return Border(wd, cl, st);
    }

    unittest
    {
        // Тест с одним стилем
        auto result1 = Border.parse("solid");
        assert(result1.style == BorderStyle.SOLID);
        assert(result1.width == Dimension(0));
        assert(result1.color == Colors.TRANSPARENT);

        // Тест со стилем и цветом
        auto result2 = Border.parse("dashed red");
        assert(result2.style == BorderStyle.DASHED);
        assert(result2.width == Dimension(0));
        assert(result2.color == Colors.RED);

        // Тест со всеми значениями
        auto result3 = Border.parse("1rem solid blue");
        assert(result3.style == BorderStyle.SOLID);
        assert(result3.width == Dimension(1, Unit.REM));
        assert(result3.color == Colors.BLUE);

        // Тест с неверным порядком значений
        auto result4 = Border.parse("blue 1rem solid");
        assert(result4.style == BorderStyle.SOLID);
        assert(result4.width == Dimension(1, Unit.REM));
        assert(result4.color == Colors.BLUE);

        // Тест с неверным значением
        bool exceptionThrown = false;
        try
        {
            auto result5 = Border.parse("invalidValue");
        }
        catch (Exception e)
        {
            exceptionThrown = true;
        }
        assert(exceptionThrown);
    }
}

enum BorderStyle
{
    NONE,
    SOLID,
    DASHED,
    DOTTED,
    DOUBLE
}