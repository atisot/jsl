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
            throw new JsonStylingException("Cannot set theme " ~ themeId ~ " as current, it was not found");
        }
        _currentThemeId = themeId;
    }

    Nullable!Theme currentTheme() @safe
    {
        if (_currentThemeId)
        {
            return Nullable!Theme(_themes[_currentThemeId]);
        }
        
        return Nullable!Theme.init;
    }

    void loadThemeFromFile(string filePath)
    {
        string content = readText(filePath);
        loadThemeFromMemory(content);
    }

    void loadThemeFromMemory(string content)
    {
        JSONValue json = parseJSON(content);
        Theme theme = Theme.parse(json);
        _themes[theme.id] = theme;
        if (_themes.length == 1)
        {
            currentTheme(theme.id);
        }
    }

    string[] themeIds()
    {
        return _themes.keys;
    }

    Nullable!Theme theme(string id)
    {
        if (id in _themes)
        {
            return Nullable!Theme(_themes[id]);
        }
        
        return Nullable!Theme.init;
    }

    void removeTheme(string id)
    {
        if (id in _themes)
        {
            _themes.remove(id);
        }
    }

    void clearThemes()
    {
        _themes.clear();
    }

    T property(T)(string styleId, string propName)
    {
        if(!currentTheme.isNull)
        {
            auto prop = findPropertyInTheme!T(currentTheme.get, styleId, propName);
            if (prop.isNull)
            {
                throw new JsonStylingException("Property " ~ propName ~ " for style `" ~ styleId ~ "` not found");
            }
            return prop.get;
        }

        throw new JsonStylingException("No current theme");
    }

    private Nullable!T findPropertyInTheme(T)(Theme theme, string styleId, string propName)
    {
        auto style = theme.style(styleId);
        if (!style.isNull)
        {
            auto prop = style.get.property!T(propName);
            if (!prop.isNull)
            {
                return prop;
            }
        else if (style.get.parentId !is null)
            {
                return findPropertyInTheme!T(theme, style.get.parentId, propName);
            }
        }

        if (theme.parentId !is null)
        {
            auto parentTheme = this.theme(theme.parentId);
            if(!parentTheme.isNull)
            {
                return findPropertyInTheme!T(parentTheme.get, styleId, propName);
            }
        }

        return Nullable!T.init;
    }
}