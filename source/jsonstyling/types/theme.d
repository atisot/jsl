module jsonstyling.types.theme;

import jsonstyling.types;
import jsonstyling.utils;

import std.algorithm;
import std.typecons;
import std.json;

class Theme
{
    private 
    {
        string _id;
        string _parentId;

        Style[string] _styles;
    }

    this(string id = null, string parentId = null)
    {
        _id = id;
        _parentId = parentId;
    }

    auto id() @property const { return _id; }
    auto parentId() @property const { return _parentId; }

    void style(Style style)
    {
        _styles[style.id] = style;
    }

    Nullable!Style style(string id)
    {
        if(id in _styles)
            return Nullable!Style(_styles[id]);

        return Nullable!Style.init;
    }

    Style[string] styles()
    {
        return _styles;
    }

    static Theme parse(JSONValue json)
    {
        Theme theme;

        try
        {
            string id = null;
            string parentId = null;

            if("id" in json && !json["id"].isNull)
                id = json["id"].str;

            if("parent" in json && !json["parent"].isNull)
                parentId = json["parent"].str;
            
            theme = new Theme(id, parentId);

            if("styles" in json)
            {
                foreach (string name, value; json["styles"].object)
                {
                    theme.style(Style.parse(value, name));
                }
            }
        }
        catch (Exception e)
        {
            throw new Exception("Error parsing theme: " ~ e.msg);
        }

        return theme;
    }

    override string toString() const
    {
        import std.string : format;
        import std.array;
        import std.conv;

        string result = "Theme(id: %s, parent: %s, styles: { %s })";

        // Преобразование стилей в строку
        string stylesStr = _styles.byKeyValue
            .map!(pair => format("%s: { %s }", pair.key, pair.value.toString()))
            .array
            .joiner(", ")
            .to!string;

        return format(result, _id ? _id : "null", _parentId ? _parentId : "null", stylesStr);
    }

    unittest
    {
        import std.json;

        // 1. Проверка создания темы без родителя.
        {
            string jsonString = `{
            "testTheme": {
                "parent": null
            }
        }`;

            auto json = parseJSON(jsonString);
            auto theme = Theme.parse(json["testTheme"]);

            assert(theme.styles.length == 0);
        }

        // 2. Проверка создания темы с родителем.
        {
            string jsonString = `{
            "testTheme": {
                "parent": "parentTheme"
            }
        }`;

            auto json = parseJSON(jsonString);
            auto theme = Theme.parse(json["testTheme"]);

            assert(theme.styles.length == 0);
        }

        // 3. Проверка добавления и получения стилей в теме.
        {
            string jsonString = `{
            "testTheme": {
                "styles": {
                    "style1": {
                        "properties": {
                            "width": "100%"
                        }
                    }
                }
            }
        }`;

            auto json = parseJSON(jsonString);
            auto theme = Theme.parse(json["testTheme"]);

            assert(theme.styles.length == 1);
            assert(theme.style("style1")
                    .get.property!Dimension("width") == Dimension(100, Unit.PERCENT));
        }

        // 4. Проверка добавления стилей в тему через метод `style`.
        {
            auto theme = new Theme("testTheme");
            auto customStyle = Style.create("customStyle").width(Dimension(50))
                .opacity(0.5f).build();
            theme.style(customStyle);

            assert(theme.styles.length == 1);
            assert(theme.style("customStyle").get.property!Dimension("width") == Dimension(50));
        }
    }
}