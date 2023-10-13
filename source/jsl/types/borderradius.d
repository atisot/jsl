module jsl.types.borderradius;

import jsl.types;
import jsl.exceptions;

import std.string;

struct BorderRadius
{
    private
    {
        Dimension _tl;
        Dimension _tr;
        Dimension _br;
        Dimension _bl;
    }

    this(Dimension topLeft, Dimension topRight, Dimension bottomRight, Dimension bottomLeft)
    {
        _tl = topLeft;
        _tr = topRight;
        _br = bottomRight;
        _bl = bottomLeft;
    }

    this(Dimension topLeft, Dimension topRightAndBottomLeft, Dimension bottomRight)
    {
        _tl = topLeft;
        _tr = topRightAndBottomLeft;
        _br = bottomRight;
        _bl = topRightAndBottomLeft;
    }

    this(Dimension topLeftAndBottomRight, Dimension topRightAndBottomLeft)
    {
        _tl = topLeftAndBottomRight;
        _tr = topRightAndBottomLeft;
        _br = topLeftAndBottomRight;
        _bl = topRightAndBottomLeft;
    }

    this(Dimension value)
    {
        _tl = value;
        _tr = value;
        _br = value;
        _bl = value;
    }

    auto topLeft() @property const { return _tl; }
    auto topRight() @property const { return _tr; }
    auto bottomRight() @property const { return _br; }
    auto bottomLeft() @property const { return _bl; }

    bool empty()
    {
        return (_tl.value == 0 && _tr.value == 0 && _br.value == 0 && _bl.value == 0);
    }

    static BorderRadius parse(string input)
    {
        // Удаляем символы ";" и пробелы с обеих сторон строки
        input = input.strip().strip(";");

        // Разделяем строку по пробелам
        auto parts = input.split();

        switch (parts.length)
        {
        case 1:
            return BorderRadius(Dimension.parse(parts[0]));

        case 2:
            return BorderRadius(Dimension.parse(parts[0]), Dimension.parse(parts[1]));

        case 3:
            return BorderRadius(Dimension.parse(parts[0]), Dimension.parse(parts[1]), Dimension.parse(
                parts[2]));

        case 4:
            return BorderRadius(
                Dimension.parse(parts[0]), 
                Dimension.parse(parts[1]), 
                Dimension.parse(parts[2]), 
                Dimension.parse(parts[3])
            );

        default:
            throw new ThemeParseException("Invalid input format for BorderRadius: " ~ input);
        }
    }

    unittest
    {
        import std.exception : assertThrown;

        // Тестирование для одного значения
        {
            auto br = BorderRadius.parse("10px;");
            assert(br.topLeft().value == 10);
            assert(br.topRight().value == 10);
            assert(br.bottomRight().value == 10);
            assert(br.bottomLeft().value == 10);
        }

        // Тестирование для двух значений
        {
            auto br = BorderRadius.parse("10px 5%");
            assert(br.topLeft().value == 10);
            assert(br.topRight().value == 5);
            assert(br.bottomRight().value == 10);
            assert(br.bottomLeft().value == 5);
        }

        // Тестирование для трех значений
        {
            auto br = BorderRadius.parse("10px 5% 2px");
            assert(br.topLeft().value == 10);
            assert(br.topRight().value == 5);
            assert(br.bottomRight().value == 2);
            assert(br.bottomLeft().value == 5);
        }

        // Тестирование для четырех значений
        {
            auto br = BorderRadius.parse("10px 5% 2px 4px");
            assert(br.topLeft().value == 10);
            assert(br.topRight().value == 5);
            assert(br.bottomRight().value == 2);
            assert(br.bottomLeft().value == 4);
        }

        // Тестирование неверного формата
        {
            assertThrown(BorderRadius.parse("10px 5% 2px 4px 6px"));
            assertThrown(BorderRadius.parse("invalid"));
        }
    }
}