module jsonstyling.manager;

import std.file;
import std.json;


import jsonstyling;

alias JsonStyling = JsonStylingManager.instance;

class JsonStylingManager {
    private {
        __gshared JsonStylingManager _instance;
        Theme[string] _themes;
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

    // Загрузка темы из файла
    void loadThemeFromFile(string filePath)
    {
        try
        {
            string content = readText(filePath);
            JSONValue json = parseJSON(content);
            Theme theme = Theme.parse(json);
            _themes[theme.id] = theme;
        }
        catch (FileException e)
        {
            throw new Exception("Error read theme file: " ~ e.msg);
        }
        catch (JSONException e) {
            throw new Exception("Error parse theme: " ~ e.msg);
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

    // Загрузка темы из ресурсов (предполагается, что у вас есть функция loadResource)
    // void loadThemeFromResource(string resourceId)
    // {
    //     try
    //     {
    //         string content = loadResource(resourceId);
    //         JSONValue json = parseJSON(content);
    //         Theme theme = Theme.parse(json);
    //         _themes[theme.id] = theme;
    //     }
    //     catch (JSONException e)
    //     {
    //         throw new Exception("Error parse theme: " ~ e.msg);
    //     }
    //     catch (Exception e)
    //     {
    //         throw new Exception("Error: " ~ e.msg);
    //     }
    // }

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
}