module jsl.types.gradient;

import jsl.types;
import jsl.exceptions;

import std.typecons;
import std.typetuple;
import std.traits;
import std.string;
import std.algorithm;
import std.array;
import std.math;
import std.regex;

// linear(167deg, rgba(134,134,134,1), #fff, rgba(134,123,134,1))
// radial(167deg, rgba(134,134,134,1), #fff)

struct Gradient
{
    float angle;
    GradientType type;
    Color[] colors;

    bool isVertical(float tolerance = 45.0)
    {
        auto gradientAngle = fmod(angle, 360.0);
        if (gradientAngle < 0)
        {
            gradientAngle += 360.0;
        }

        // Проверка для вертикального градиента (0 градусов +/- допуск или 180 градусов +/- допуск)
        return (fabs(gradientAngle - 0) <= tolerance) ||
            (fabs(gradientAngle - 180) <= tolerance) ||
            (fabs(gradientAngle - 360) <= tolerance);
    }

    static Gradient parse(string gradientString)
    {
        // Регулярное выражение для поиска значений градиента
        auto gradientRegex = regex(r"(\w+)\((\d+)deg,\s*(.+)\)");
        auto match = matchFirst(gradientString, gradientRegex);

        Gradient gradient;

        // Установить тип градиента
        switch (match[1])
        {
        case "linear":
            gradient.type = GradientType.LINEAR;
            break;
        case "radial":
            gradient.type = GradientType.RADIAL;
            break;
        default:
            throw new Exception("Unknown gradient type.");
        }

        // Установить угол градиента
        gradient.angle = to!float(match[2]);

        // Парсинг цветов
        string colorsString = match[3];
        string[] colorStrings = Color.splitColors(colorsString);

        foreach (colorStr; colorStrings)
        {
            // Создание цвета из строки и добавление в массив
            Color color = Color.parse(colorStr);
            gradient.colors ~= color;
        }

        return gradient;
    }
}

enum GradientType : string
{
    RADIAL = "radial",
    LINEAR = "linear"
}

unittest
{
    // Тестирование парсинга линейного градиента
    {
        string gradientStr = "linear(167deg, rgba(134,134,134,0.5), #fff, rgba(134,123,134,1))";
        Gradient gradient = Gradient.parse(gradientStr);

        assert(gradient.type == GradientType.LINEAR, "Expected linear gradient type");
        assert(approxEqual(gradient.angle, 167.0), "Expected angle to be 167 degrees");
        assert(gradient.colors.length == 3, "Expected 3 colors in the gradient");

        // Проверяем каждый цвет
        assert(gradient.colors[0].equals(Color(134, 134, 134, 128)), "First color does not match");
        assert(gradient.colors[1].equals(Color(255, 255, 255, 255)), "Second color does not match");
        assert(gradient.colors[2].equals(Color(134, 123, 134, 255)), "Third color does not match");
    }

    // Тестирование парсинга радиального градиента
    {
        string gradientStr = "radial(167deg, rgba(134,134,134,1), #fff)";
        Gradient gradient = Gradient.parse(gradientStr);

        assert(gradient.type == GradientType.RADIAL, "Expected radial gradient type");
        assert(approxEqual(gradient.angle, 167.0), "Expected angle to be 167 degrees");
        assert(gradient.colors.length == 2, "Expected 2 colors in the gradient");

        // Проверяем каждый цвет
        assert(gradient.colors[0].equals(Color(134, 134, 134, 255)), "First color does not match");
        assert(gradient.colors[1].equals(Color(255, 255, 255, 255)), "Second color does not match");
    }

    bool approxEqual(float a, float b, float tolerance = 0.001f)
    {
        return fabs(a - b) <= tolerance;
    }
}