module jsl.types.boxshadow;

import jsl.types;
import jsl.exceptions;

import std.string;

struct BoxShadow
{
    Dimension offsetX;
    Dimension offsetY;
    Dimension blurRadius;
    Dimension spreadRadius;
    Color color;
    bool inset;

    static BoxShadow parse(string input)
    {
        BoxShadow shadow;

        // Установка значений по умолчанию
        shadow.offsetX = Dimension(0);
        shadow.offsetY = Dimension(0);
        shadow.blurRadius = Dimension(0);
        shadow.spreadRadius = Dimension(0);
        shadow.color = Color(0, 0, 0, 0); // предположим, что это черный цвет
        shadow.inset = false;

        int dimensionCount = 0;

        auto parts = input.split();

        foreach (part; parts)
        {
            part = part.strip;

            if (part == "inset")
            {
                shadow.inset = true;
                continue;
            }

            try
            {
                shadow.color = Color.parse(part);
                continue;
            }
            catch (Exception e)
            { // не цвет
            }

            try
            {
                Dimension dim = Dimension.parse(part);

                switch (dimensionCount)
                {
                case 0:
                    shadow.offsetX = dim;
                    break;
                case 1:
                    shadow.offsetY = dim;
                    break;
                case 2:
                    shadow.blurRadius = dim;
                    break;
                case 3:
                    shadow.spreadRadius = dim;
                    break;
                default:
                    throw new ThemeParseException("Too many dimensions provided");
                }

                dimensionCount++;

                continue;
            }
            catch (Exception e)
            { // не измерение
            }
        }

        // Проверка на минимальное количество измерений (должно быть хотя бы 2: offsetX и offsetY)
        if (dimensionCount < 2)
        {
            throw new ThemeParseException("Insufficient dimensions provided");
        }

        return shadow;
    }

    unittest
    {
        // Тестирование базового случая
        {
            auto shadow = BoxShadow.parse("10px 10px 5px 5px #888888");
            assert(shadow.offsetX == Dimension(10));
            assert(shadow.offsetY == Dimension.parse("10px"));
            assert(shadow.blurRadius == Dimension.parse("5px"));
            assert(shadow.spreadRadius == Dimension.parse("5px"));
            assert(shadow.color == Color.parse("#888888"));
            assert(shadow.inset == false);
        }

        // Тестирование с ключевым словом 'inset'
        {
            auto shadow = BoxShadow.parse("inset 10px 10px 5px 5px #888888");
            assert(shadow.offsetX == Dimension.parse("10px"));
            assert(shadow.offsetY == Dimension.parse("10px"));
            assert(shadow.blurRadius == Dimension.parse("5px"));
            assert(shadow.spreadRadius == Dimension.parse("5px"));
            assert(shadow.color == Color.parse("#888888"));
            assert(shadow.inset == true);
        }

        // Тестирование без spreadRadius
        {
            auto shadow = BoxShadow.parse("10px 10px 5px #888888");
            assert(shadow.offsetX == Dimension.parse("10px"));
            assert(shadow.offsetY == Dimension.parse("10px"));
            assert(shadow.blurRadius == Dimension.parse("5px"));
            assert(shadow.spreadRadius.value == 0);
            assert(shadow.color == Color.parse("#888888"));
            assert(shadow.inset == false);
        }

        // Тестирование без blurRadius и spreadRadius
        {
            auto shadow = BoxShadow.parse("10px 10px #888888");
            assert(shadow.offsetX == Dimension.parse("10px"));
            assert(shadow.offsetY == Dimension.parse("10px"));
            assert(shadow.blurRadius.value == 0);
            assert(shadow.spreadRadius.value == 0);
            assert(shadow.color == Color.parse("#888888"));
            assert(shadow.inset == false);
        }

        // Тестирование неверного ввода
        bool exceptionThrown = false;
        try
        {
            auto shadow = BoxShadow.parse("10px #888888");
        }
        catch (Exception e)
        {
            exceptionThrown = true;
        }
        assert(exceptionThrown);
    }
}