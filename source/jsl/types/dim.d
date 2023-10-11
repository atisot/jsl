module jsl.types.dim;

import jsl.types;
import jsl.exceptions;

import std.regex;
import std.string;

struct Dimension
{
    float value;
    Unit unit = Unit.NONE;

    bool empty()
    {
        return (unit == Unit.NONE);
    }



    static Dimension parse(string input)
    {
        Dimension dim;

        auto re = regex(`^(-?\d+(\.\d+)?)([a-z%]*)?$`);
        auto match = matchFirst(input, re);

        if (!match)
            throw new ThemeParseException("Invalid dimension format: " ~ input);

        dim.value = to!float(match[1]);

        if (match[3] == "")
        {
            dim.unit = Unit.PX;
            if (dim.value != to!int(dim.value))
                throw new ThemeParseException(
                    "Invalid dimension format with `" ~ input ~ "`: pixel values must be integers.");
        }
        else
        {
            switch (match[3])
            {
            case "px":
                if (dim.value != to!int(dim.value))
                    throw new ThemeParseException(
                        "Invalid dimension format with `" ~ input ~ "`: pixel values must be integers.");
                dim.unit = Unit.PX;
                break;
            case "cm":
                dim.unit = Unit.CM;
                break;
            case "mm":
                dim.unit = Unit.MM;
                break;
            case "in":
                dim.unit = Unit.INCH;
                break;
            case "pt":
                dim.unit = Unit.PT;
                break;
            case "pc":
                dim.unit = Unit.PC;
                break;
            case "em":
                dim.unit = Unit.EM;
                break;
            case "rem":
                dim.unit = Unit.REM;
                break;
            case "ex":
                dim.unit = Unit.EX;
                break;
            case "ch":
                dim.unit = Unit.CH;
                break;
            case "vw":
                dim.unit = Unit.VW;
                break;
            case "vh":
                dim.unit = Unit.VH;
                break;
            case "vmin":
                dim.unit = Unit.VMIN;
                break;
            case "vmax":
                dim.unit = Unit.VMAX;
                break;
            case "%":
                dim.unit = Unit.PERCENT;
                break;
            default:
                throw new ThemeParseException(
                    "Invalid dimension format with `" ~ input ~ "`: Unknown unit '" ~ match[3] ~ "'.");
            }
        }

        return dim;
    }

    unittest
    {
        // Позитивные тесты
        auto dim1 = parse("100px");
        assert(dim1.value == 100);
        assert(dim1.unit == Unit.PX);

        auto dim2 = parse("-50.5%");
        assert(dim2.value == -50.5);
        assert(dim2.unit == Unit.PERCENT);

        auto dim3 = parse("10");
        assert(dim3.value == 10);
        assert(dim3.unit == Unit.PX);

        auto dim4 = parse("2.54in");
        import std.math;

        assert(feqrel(dim4.value, 2.54f) > float.mant_dig - 2);
        assert(dim4.unit == Unit.INCH);

        // Негативные тесты (должны вызывать исключения)
        bool exceptionThrown;

        exceptionThrown = false;
        try
        {
            parse("100.5px"); // Пиксели должны быть целыми числами
        }
        catch (Exception e)
        {
            exceptionThrown = true;
        }
        assert(exceptionThrown);

        exceptionThrown = false;
        try
        {
            parse("abc"); // Неверный формат
        }
        catch (Exception e)
        {
            exceptionThrown = true;
        }
        assert(exceptionThrown);

        exceptionThrown = false;
        try
        {
            parse("100unknown"); // Неизвестная единица измерения
        }
        catch (Exception e)
        {
            exceptionThrown = true;
        }
        assert(exceptionThrown);
    }
}

struct Dimensions
{
    Dimension[4] box;
    alias box this;

    this(Dimension value)
    {
        box = [value, value, value, value];
    }

    this(Dimension value1, Dimension value2)
    {
        box = [value1, value2, value1, value2];
    }

    this(Dimension value1, Dimension value2, Dimension value3)
    {
        box = [value1, value2, value3, value2];
    }

    this(Dimension value1, Dimension value2, Dimension value3, Dimension value4)
    {
        box = [value1, value2, value3, value4];
    }

    this(float value)
    {
        box = [
            Dimension(value), Dimension(value), Dimension(value), Dimension(value)
        ];
    }

    this(float value1, float value2)
    {
        box = [
            Dimension(value1), Dimension(value2), Dimension(value1),
            Dimension(value2)
        ];
    }

    this(float value1, float value2, float value3)
    {
        box = [
            Dimension(value1), Dimension(value2), Dimension(value3),
            Dimension(value2)
        ];
    }

    this(float value1, float value2, float value3, float value4)
    {
        box = [
            Dimension(value1), Dimension(value2), Dimension(value3),
            Dimension(value4)
        ];
    }

    auto top() @property const
    {
        return box[0];
    }

    auto right() @property const
    {
        return box[1];
    }

    auto bottom() @property const
    {
        return box[2];
    }

    auto left() @property const
    {
        return box[3];
    }

    static Dimensions parse(string input)
    {
        auto components = input.replace(";", "").split();

        Dimension[] temp;
        foreach (component; components)
        {
            temp ~= Dimension.parse(component.strip);
        }

        Dimensions dims;
        switch (temp.length)
        {
            case 1:
                dims = Dimensions(temp[0]);
                break;
            case 2:
                dims = Dimensions(temp[0], temp[1]);
                break;
            case 3:
                dims = Dimensions(temp[0], temp[1], temp[2]);
                break;
            case 4:
                dims = Dimensions(temp[0], temp[1], temp[2], temp[3]);
                break;
            default:
                throw new ThemeParseException("Invalid input: More than 4 values provided for: " ~ input);
        }

        return dims;
    }

    unittest
    {
        // Тест с одним значением
        Dimensions result1 = Dimensions.parse("1rem");
        assert(result1.top == Dimension(1, Unit.REM));

        // Тест с двумя значениями
        Dimensions result2 = Dimensions.parse("1rem 2rem");
        assert(result2.top == Dimension(1, Unit.REM));
        assert(result2.right == Dimension(2, Unit.REM));

        // Тест с тремя значениями
        Dimensions result3 = Dimensions.parse("1rem 2rem 3rem");
        assert(result3.top == Dimension(1, Unit.REM));
        assert(result3.left == Dimension(2, Unit.REM));
        assert(result3.bottom == Dimension(3, Unit.REM));

        // Тест с четырьмя значениями
        Dimensions result4 = Dimensions.parse("1rem 2rem 3rem 4rem");
        assert(result4.top == Dimension(1, Unit.REM));
        assert(result4.right == Dimension(2, Unit.REM));
        assert(result4.bottom == Dimension(3, Unit.REM));
        assert(result4.left == Dimension(4, Unit.REM));

        // Тест с неверным количеством значений
        bool exceptionThrown = false;
        try
        {
            Dimensions result5 = Dimensions.parse("1rem 2rem 3rem 4rem 5rem");
        }
        catch (Exception e)
        {
            exceptionThrown = true;
        }
        assert(exceptionThrown);
    }
}

enum Unit : string
{
    NONE = "none",
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