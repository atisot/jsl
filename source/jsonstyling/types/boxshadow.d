module jsonstyling.types.boxshadow;

import jsonstyling.types;

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
        shadow.inset = false;

        auto parts = input.split();

        foreach (part; parts)
        {
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
            {
            }

            try
            {
                Dimension dim = Dimension.parse(part);

                if (shadow.offsetX.empty)
                    shadow.offsetX = dim;
                else if (shadow.offsetY.empty)
                    shadow.offsetY = dim;
                else if (shadow.blurRadius.empty)
                    shadow.blurRadius = dim;
                else if (shadow.spreadRadius.empty)
                    shadow.spreadRadius = dim;

                continue;
            }
            catch (Exception e)
            {
            }
        }

        // Проверяем, что все необходимые поля заполнены
        if (shadow.offsetX.empty || shadow.offsetY.empty)
            throw new Exception("Invalid box-shadow value: " ~ input);

        return shadow;
    }

    unittest
    {
        // Тестирование базового случая
        {
            auto shadow = BoxShadow.parse("10px 10px 5px 5px #888888");
            assert(shadow.offsetX == Dimension.parse("10px"));
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
            assert(shadow.spreadRadius.empty);
            assert(shadow.color == Color.parse("#888888"));
            assert(shadow.inset == false);
        }

        // Тестирование без blurRadius и spreadRadius
        {
            auto shadow = BoxShadow.parse("10px 10px #888888");
            assert(shadow.offsetX == Dimension.parse("10px"));
            assert(shadow.offsetY == Dimension.parse("10px"));
            assert(shadow.blurRadius.empty);
            assert(shadow.spreadRadius.empty);
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