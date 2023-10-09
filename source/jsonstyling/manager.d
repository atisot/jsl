module jsonstyling.manager;

import std.file;
import std.json;
import std.typecons;

import jsonstyling;
import etc.c.curl;

alias JsonStyling = JsonStylingManager.instance;

class JsonStylingManager {
    private {
        __gshared JsonStylingManager _instance;
        Theme[string] _themes;
        string _currentThemeId;
    }

    protected this() {
    }

    ~this()
    {
        clearThemes();
    }

    static JsonStylingManager instance() {
        if (!_instance) {
            synchronized (JsonStylingManager.classinfo) {
                if (!_instance)
                    _instance = new JsonStylingManager;
            }
        }

        return _instance;
    }

    void currentTheme(string themeId)
    {
        if (themeId !in _themes)
        {
            throw new Exception("Theme not found: " ~ themeId);
        }
        _currentThemeId = themeId;
    }

    // Получение текущей темы
    Theme currentTheme()
    {
        if (_currentThemeId)
        {
            return _themes[_currentThemeId];
        }
        else
        {
            throw new Exception("No current theme set.");
        }
    }

    // Загрузка темы из файла
    void loadThemeFromFile(string filePath)
    {
        try
        {
            string content = readText(filePath);
            loadThemeFromMemory(content);
        }
        catch (FileException e)
        {
            throw new Exception("Error read theme file: " ~ e.msg);
        }
        catch (Exception e)
        {
            throw new Exception("Error: " ~ e.msg);
        }
    }

    // Загрузка темы из памяти (строки)
    void loadThemeFromMemory(string content)
    {
        try
        {
            JSONValue json = parseJSON(content);
            Theme theme = Theme.parse(json);
            _themes[theme.id] = theme;
            if (_themes.length == 1)
            {
                currentTheme(theme.id);
            }
        }
        catch (JSONException e)
        {
            throw new Exception("Error parse theme: " ~ e.msg);
        }
        catch (Exception e)
        {
            throw new Exception("Error: " ~ e.msg);
        }
    }

    // Получение списка ID всех тем
    string[] themeIds()
    {
        return _themes.keys;
    }

    // Получение темы по ID
    Theme theme(string id)
    {
        if (id in _themes)
        {
            return _themes[id];
        }
        else
        {
            throw new Exception("Theme not found: " ~ id);
        }
    }

    // Удаление темы по ID
    void removeTheme(string id)
    {
        if (id in _themes)
        {
            _themes.remove(id);
        }
    }

    // Очистка всех тем
    void clearThemes()
    {
        _themes.clear();
    }

    T property(T)(string styleId, string propName)
    {
        auto prop = findPropertyInTheme!T(currentTheme, styleId, propName);
        if(prop.isNull)
        {
            throw new Exception("Property " ~ propName ~ " not found");
        }
        return prop.get;
    }

    private Nullable!T findPropertyInTheme(T)(Theme theme, string styleId, string propName)
    {
        // Попробовать найти стиль в текущей теме
        auto style = theme.style(styleId);
        if (!style.isNull)
        {
            // Попробовать найти свойство в найденном стиле
            auto prop = style.get.property!T(propName);
            if (!prop.isNull)
            {
                return prop;
            }
            // Если свойство не найдено, ищем в родительском стиле
        else if (style.get.parentId !is null)
            {
                return findPropertyInTheme!T(theme, style.get.parentId, propName);
            }
        }

        // Если стиль или свойство не найдено в текущей теме, ищем в родительской теме
        if (theme.parentId !is null)
        {
            Theme parentTheme = this.theme(theme.parentId);
            return findPropertyInTheme!T(parentTheme, styleId, propName);
        }

        // Если стиль или свойство не найдено и нет родительской темы
        return Nullable!T.init;
    }

    Nullable!Style findStyleInTheme(Theme theme, string styleId)
    {
        auto style = theme.style(styleId);
        if (!style.isNull)
        {
            return style;
        }
        else if (theme.parentId !is null)
        {
            Theme parentTheme = this.theme(theme.parentId);
            return findStyleInTheme(parentTheme, styleId);
        }
        else
        {
            return Nullable!Style.init;
        }
    }
}