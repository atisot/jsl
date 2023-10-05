module jsonstyling.parser;

import jsonstyling;

import std.typecons;
import std.traits;
import std.json;
import std.conv;
import std.regex;
import std.exception;
import std.string;
import std.algorithm;
import std.math;
import std.stdio;
import std.array;

Dimension parseDimension(string input)
{
    // Регулярное выражение для разделения числа и единицы измерения
    auto re = regex(`^(-?\d+(\.\d+)?)([a-z%]*)$`);
    auto match = matchFirst(input, re);

    if (!match)
        throw new Exception("Invalid format: The input does not match the expected pattern.");

    // Извлекаем значение и единицу измерения
    float value;
    try
    {
        value = to!float(match[1]);
    }
    catch (ConvException)
    {
        throw new Exception("Invalid format: The numeric part of the input is not a valid number.");
    }

    string unitStr = match[3];

    Unit unit;

    if (unitStr == "")
    {
        unit = Unit.PX;
        if (value != to!int(value)) // Проверка на целое число
            throw new Exception("Invalid format: Pixel values must be integers.");
    }
    else
    {
        switch (unitStr)
        {
        case "px":
            if (value != to!int(value)) // Проверка на целое число
                throw new Exception("Invalid format: Pixel values must be integers.");
            unit = Unit.PX;
            break;
        case "cm":
            unit = Unit.CM;
            break;
        case "mm":
            unit = Unit.MM;
            break;
        case "in":
            unit = Unit.INCH;
            break;
        case "pt":
            unit = Unit.PT;
            break;
        case "pc":
            unit = Unit.PC;
            break;
        case "em":
            unit = Unit.EM;
            break;
        case "rem":
            unit = Unit.REM;
            break;
        case "ex":
            unit = Unit.EX;
            break;
        case "ch":
            unit = Unit.CH;
            break;
        case "vw":
            unit = Unit.VW;
            break;
        case "vh":
            unit = Unit.VH;
            break;
        case "vmin":
            unit = Unit.VMIN;
            break;
        case "vmax":
            unit = Unit.VMAX;
            break;
        case "%":
            unit = Unit.PERCENT;
            break;
        default:
            throw new Exception("Invalid format: Unknown unit '" ~ unitStr ~ "'.");
        }
    }

    return Dimension(value, unit);
}

unittest
{
    // Позитивные тесты
    auto dim1 = parseDimension("100px");
    assert(dim1.value == 100);
    assert(dim1.unit == Unit.PX);

    auto dim2 = parseDimension("-50.5%");
    assert(dim2.value == -50.5);
    assert(dim2.unit == Unit.PERCENT);

    auto dim3 = parseDimension("10");
    assert(dim3.value == 10);
    assert(dim3.unit == Unit.PX);

    auto dim4 = parseDimension("2.54in");
    import std.math;

    assert(feqrel(dim4.value, 2.54f) > float.mant_dig - 2);
    assert(dim4.unit == Unit.INCH);

    // Негативные тесты (должны вызывать исключения)
    bool exceptionThrown;

    exceptionThrown = false;
    try
    {
        parseDimension("100.5px"); // Пиксели должны быть целыми числами
    }
    catch (Exception e)
    {
        exceptionThrown = true;
    }
    assert(exceptionThrown);

    exceptionThrown = false;
    try
    {
        parseDimension("abc"); // Неверный формат
    }
    catch (Exception e)
    {
        exceptionThrown = true;
    }
    assert(exceptionThrown);

    exceptionThrown = false;
    try
    {
        parseDimension("100unknown"); // Неизвестная единица измерения
    }
    catch (Exception e)
    {
        exceptionThrown = true;
    }
    assert(exceptionThrown);
}

Color parseColor(string input)
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
            throw new Exception("Invalid hex color format");
        }
    }
    else if (matchFirst(input, rgbPattern))
    {
        auto rgbMatch = matchFirst(input, rgbPattern);
        return Color(to!ubyte(rgbMatch[1]),
        to!ubyte(rgbMatch[2]),
        to!ubyte(rgbMatch[3]),
        defaultAlpha);
    }
    else if (matchFirst(input, rgbaPattern))
    {
        auto rgbaMatch = matchFirst(input, rgbaPattern);
        return Color(to!ubyte(rgbaMatch[1]),
        to!ubyte(rgbaMatch[2]),
        to!ubyte(rgbaMatch[3]),
        to!ubyte(round(to!float(rgbaMatch[4]) * 255)));
    }
    else if (matchFirst(input, hslPattern))
    {
        auto hslMatch = matchFirst(input, hslPattern);
        return hslToRgb(to!float(hslMatch[1]),
        to!float(hslMatch[2]) / 100.0,
        to!float(hslMatch[3]) / 100.0);
    }
    else if (matchFirst(input, hslaPattern))
    {
        auto hslaMatch = matchFirst(input, hslaPattern);
        return hslToRgb(to!float(hslaMatch[1]),
        to!float(hslaMatch[2]) / 100.0,
        to!float(hslaMatch[3]) / 100.0,
        to!ubyte(round(to!float(hslaMatch[4]) * 255)));
    }
    else
    {
        throw new Exception("Invalid color format");
    }
}

unittest
{
    // Hex
    assert(parseColor("#F00") == Color(255, 0, 0, 255));
    assert(parseColor("#FF0000") == Color(255, 0, 0, 255));
    assert(parseColor("#FF000080") == Color(255, 0, 0, 128));

    // RGB
    assert(parseColor("rgb(255, 0, 0)") == Color(255, 0, 0, 255));

    // RGBA
    assert(parseColor("rgba(255, 0, 0, 0.5)") == Color(255, 0, 0, 128));

    // HSL
    assert(parseColor("hsl(0, 100%, 50%)") == Color(255, 0, 0, 255));
    assert(parseColor("hsl(120, 100%, 50%)") == Color(0, 255, 0, 255));
    assert(parseColor("hsl(240, 100%, 50%)") == Color(0, 0, 255, 255));

    // HSLA
    assert(parseColor("hsla(0, 100%, 50%, 0.5)") == Color(255, 0, 0, 128));
    assert(parseColor("hsla(120, 100%, 50%, 0.5)") == Color(0, 255, 0, 128));
    assert(parseColor("hsla(240, 100%, 50%, 0.5)") == Color(0, 0, 255, 128));

    // string
    assert(parseColor("green") == Color(0, 255, 0, 255));
    assert(parseColor("seashell") == Color(255, 245, 238, 255));

    //TODO: отрицательные тесты
}

Tuple!(Nullable!BorderStyle, Nullable!Dimension, Nullable!Color) parseBorder(string input)
{
    // Удалите возможные точки с запятой и разделите строку на компоненты
    auto components = input.replace(";", "").split();

    Nullable!BorderStyle style = Nullable!BorderStyle.init;
    Nullable!Dimension width = Nullable!Dimension.init;
    Nullable!Color color = Nullable!Color.init;

    foreach (component; components)
    {
        const string[] styles = [EnumMembers!BorderStyle].map!(e => to!string(e)).array;

        if(styles.canFind!(s => s == component.toUpper))
        {
            style = Nullable!BorderStyle(component.toUpper.to!BorderStyle);
        }
        else
        {
            try
            {
                width = Nullable!Dimension(parseDimension(component));
            }
            catch (Exception e)
            {
                try
                {
                    color = parseColor(component);
                }
                catch (Exception e2){}
            }
        }
    }

    return tuple(style, width, color);
}

unittest
{
    // Тест с одним стилем
    auto result1 = parseBorder("solid");
    assert(result1[0].isNull == false);
    assert(result1[0].get == BorderStyle.SOLID);
    assert(result1[1].isNull == true);
    assert(result1[2].isNull == true);

    // Тест со стилем и цветом
    auto result2 = parseBorder("dashed red");
    assert(result2[0].isNull == false);
    assert(result2[0].get == BorderStyle.DASHED);
    assert(result2[1].isNull == true);
    assert(result2[2].isNull == false);
    assert(result2[2].get == Colors.RED);

    // Тест со всеми значениями
    auto result3 = parseBorder("1rem solid blue");
    assert(result3[0].isNull == false);
    assert(result3[0].get == BorderStyle.SOLID);
    assert(result3[1].isNull == false);
    assert(result3[1].get == Dimension(1, Unit.REM));
    assert(result3[2].isNull == false);
    assert(result3[2].get == Colors.BLUE);

    // Тест с неверным порядком значений
    auto result4 = parseBorder("blue 1rem solid");
    assert(result4[0].isNull == false);
    assert(result4[0].get == BorderStyle.SOLID);
    assert(result4[1].isNull == false);
    assert(result4[1].get == Dimension(1, Unit.REM));
    assert(result4[2].isNull == false);
    assert(result4[2].get == Colors.BLUE);

    // Тест с неверным значением
    bool exceptionThrown = false;
    try
    {
        auto result5 = parseBorder("invalidValue");
        assert(result5[0].isNull == true);
        assert(result5[1].isNull == true);
        assert(result5[2].isNull == true);
    }
    catch (Exception e)
    {
        exceptionThrown = true;
    }
    assert(!exceptionThrown);
}

Dimension[] parseDimensions(string input)
{
    auto components = input.replace(";", "").split();

    if (components.length > 4)
    {
        throw new Exception("Invalid input: More than 4 values provided.");
    }

    Dimension[] dimensions;

    foreach (component; components)
    {
        dimensions ~= parseDimension(component);
    }

    return dimensions;
}

unittest
{
    // Тест с одним значением
    auto result1 = parseDimensions("1rem");
    assert(result1.length == 1);
    assert(result1[0] == Dimension(1, Unit.REM));

    // Тест с двумя значениями
    auto result2 = parseDimensions("1rem 2rem");
    assert(result2.length == 2);
    assert(result2[0] == Dimension(1, Unit.REM));
    assert(result2[1] == Dimension(2, Unit.REM));

    // Тест с тремя значениями
    auto result3 = parseDimensions("1rem 2rem 3rem");
    assert(result3.length == 3);
    assert(result3[0] == Dimension(1, Unit.REM));
    assert(result3[1] == Dimension(2, Unit.REM));
    assert(result3[2] == Dimension(3, Unit.REM));

    // Тест с четырьмя значениями
    auto result4 = parseDimensions("1rem 2rem 3rem 4rem");
    assert(result4.length == 4);
    assert(result4[0] == Dimension(1, Unit.REM));
    assert(result4[1] == Dimension(2, Unit.REM));
    assert(result4[2] == Dimension(3, Unit.REM));
    assert(result4[3] == Dimension(4, Unit.REM));

    // Тест с неверным количеством значений
    bool exceptionThrown = false;
    try
    {
        auto result5 = parseDimensions("1rem 2rem 3rem 4rem 5rem");
    }
    catch (Exception e)
    {
        exceptionThrown = true;
    }
    assert(exceptionThrown);
}