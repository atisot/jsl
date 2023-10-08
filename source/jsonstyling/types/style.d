module jsonstyling.types.style;

import std.typecons;
import std.traits;
import std.algorithm;
import std.json;

import jsonstyling.types;
import jsonstyling.utils;

class Style
{
    private
    {
        string _id;
        string _parentId;
        IProperty[string] _properties;
        Style[string] _states;
    }

    private this(string id, string parentId = null)
    {
        _id = id;
        _parentId = parentId;
    }

    auto id() @property const
    {
        return _id;
    }

    auto parentId() @property const
    {
        return _parentId;
    }

    bool propertyExists(string name)
    {
        return ((name in _properties) !is null);
    }

    bool stateExists(string name)
    {
        return ((name in _states) !is null);
    }

    void property(T)(string name, T value)
    {
        if(!canFindProperty(name))
            throw new Exception(format("The %s style property is not valid", name));

        auto prop = new Property!T(value);
        _properties[name] = prop;
    }

    Nullable!T property(T)(string name)
    {
        if (propertyExists(name))
        {
            //TODO: проблема с кастованием
            auto prop = cast(Property!T) _properties[name];
            return Nullable!T(prop.get);
        }

        return Nullable!T.init;
    }

    void state(string name, Style style)
    {
        _states[name] = style;
    }

    Nullable!Style state(string name)
    {
        if (stateExists(name))
        {
            return Nullable!Style(_states[name]);
        }

        return Nullable!Style.init;
    }

    Nullable!T stateProperty(T)(string stateName, string propName)
    {
        auto state = this.state(stateName);
        if (state.isNull)
        {
            return Nullable!T.init;
        }
        
        if (state.get.propertyExists(propName))
        {
            return state.get.property!T(propName);
        }

        return Nullable!T.init;
    }

    Style copy()
    {
        Style newStyle = new Style(_id, _parentId);

        foreach (key, prop; _properties)
        {
            newStyle._properties[key] = prop;
        }

        foreach (key, state; _states)
        {
            newStyle._states[key] = state.copy;
        }

        return newStyle;
    }

    override string toString() const
    {
        import std.string : format;
        import std.algorithm;
        import std.array;
        import std.conv;

        string result = "Style(id: %s, parent: %s, properties: { %s }, states: { %s })";

        // Convert properties to string
        string propertiesStr = _properties.byKeyValue
            .map!(pair => format("%s: %s", pair.key, pair.value))
            .array
            .joiner("; ")
            .to!string;

        // Convert states to string
        string statesStr = _states.byKeyValue
            .map!(pair => format("%s: { properties: { %s } }", pair.key, pair.value._properties.byKeyValue.map!(
                    p => format("%s: %s", p.key, p.value.toString())).array.joiner("; ").to!string))
            .array
            .joiner("; ")
            .to!string;

        return format(result, _id, _parentId ? _parentId : "null", propertiesStr, statesStr);
    }

    static class StyleBuilder
    { 
        Style style;

        this(string id, string parentId)
        {
            style = new Style(id, parentId);
        }

        StateStyleBulder forState(string state)
        {
            return new StateStyleBulder(state, this);
        }

        StyleBuilder state(string name, Style st)
        {
            style.state(name, st.copy);
            return this;
        }

        StyleBuilder end()
        {
            return this;
        }

        Style build()
        {
            return style.copy();
        }

        //pragma(msg, addProperties!(props, typeof(this))); // вывод того, что сгенерирует шаблон
        mixin(addProperties!(props, typeof(this)));
    }

    static class StateStyleBulder : StyleBuilder
    {
        private StyleBuilder parentBuilder;
        private string state;

        this(string state, StyleBuilder builder)
        {
            super(null, null);
            this.state = state;
            parentBuilder = builder;
        }

        override StyleBuilder end()
        {
            parentBuilder.style.state(state, style.copy());

            // Возвращаем родительский билдер
            return parentBuilder;
        }
    }

    static StyleBuilder create(string id = null, string parentId = null)
    {
        return new StyleBuilder(id, parentId);
    }

    static Style parse(JSONValue json, string styleId)
    {
        Style.StyleBuilder styleBuilder;

        try
        {
            if ("parent" in json && json["parent"].type == JSONType.string)
            {
                styleBuilder = Style.create(styleId, json["parent"].str);
            }
            else
            {
                styleBuilder = Style.create(styleId);
            }

            if ("properties" in json && json["properties"].type == JSONType.object)
            {
                foreach (string propName, propValue; json["properties"].object)
                {
                    if (canFindProperty(propName))
                    {
                        switch (propName)
                        {
                            mixin(Style.generateSwitchCases());
                            default:
                                throw new Exception("Unknown property:" ~ propName);
                        }
                    }
                    else 
                    {
                        throw new Exception("Unknown property:" ~ propName);
                    }
                }
            }

            if ("states" in json && json["states"].type == JSONType.object)
            {
                foreach (string stateName, state; json["states"].object)
                {
                    styleBuilder.state(stateName, Style.parse(state, styleId));
                }
            }
        }
        catch (Exception e)
        {
            throw new Exception("Error in style json");
        }

        return styleBuilder.build;
    }

    private static T parseProperty(T)(JSONValue propValue)
    {
        static if (isSimpleType!T || isEnum!T)
        {
            return to!T(propValue.str);
        }
        else static if (isArray!T && (T.stringof == Dimensions.stringof))
        {
            return Dimension.parseDims(propValue.str);
        }
        else
        {
            return T.parse(propValue.str);
        }
    }

    private static string generateSwitchCases()
    {
        string result;

        for (size_t i = 0; i < props.length; i += 2)
        {
            string propName = props[i];
            string propType = props[i + 1];
            string memberName = toMemberName(propName);

            result ~= format("case \"%s\":\nstyleBuilder.%s(parseProperty!(%s)(propValue));\nbreak;\n", propName, memberName, propType
            );
        }

        return result;
    }
}

unittest
{
    // Тестирование установки и получения свойств
    auto customStyle = Style.create().width(Dimension(50)).opacity(0.5f).build();
    assert(customStyle.property!Dimension("width").get == Dimension(50));
    assert(customStyle.property!float("opacity").get == 0.5f);

    //Тестирование установки и получения свойств состояний
    auto customStyle2 = Style.create().forState("focus").color(Colors.CORAL).end.build;
    assert(customStyle2.state("focus").get.property!Color("color").get == Colors.CORAL);
    assert(customStyle2.stateProperty!Color("focus", "color").get == Colors.CORAL);

    import std.json;

    // 1. Проверка корректного создания стиля без родителя.
    {
        string jsonString = `{
            "testStyle": {
                "parent": null
            }
        }`;

        auto json = parseJSON(jsonString);
        auto style = Style.parse(json["testStyle"], "testStyle");
        assert(style.id == "testStyle");
        assert(style.parentId is null);
    }

    // 2. Проверка корректного создания стиля с родителем.
    {
        string jsonString = `{
            "testStyle": {
                "parent": "parentStyle"
            }
        }`;

        auto json = parseJSON(jsonString);
        auto style = Style.parse(json["testStyle"], "testStyle");

        assert(style.id == "testStyle");
        assert(style.parentId == "parentStyle");
    }

    // 3. Проверка обработки свойств.
    {
        string jsonString = `{
            "testStyle": {
                "properties": {
                    "width": "100%",
                    "height": "50%"
                }
            }
        }`;

        auto json = parseJSON(jsonString);
        auto style = Style.parse(json["testStyle"], "testStyle");

        assert(style.property!Dimension("width") == Dimension(100, Unit.PERCENT));
        assert(style.property!Dimension("height") == Dimension(50, Unit.PERCENT));
    }

    // 4. Проверка обработки состояний.
    {
        string jsonString = `{
            "testStyle": {
                "states": {
                    "active": {
                        "properties": {
                            "width": "120%"
                        }
                    }
                }
            }
        }`;

        auto json = parseJSON(jsonString);
        auto style = Style.parse(json["testStyle"], "testStyle");

        assert(!style.state("active").isNull);

        assert(style.state("active")
                .get.property!Dimension("width") == Dimension(120, Unit.PERCENT));
    }

    // 5. Проверка обработки недопустимых свойств.
    bool exceptionThrown = false;
    try
    {
        string jsonString = `{
            "testStyle": {
                "properties": {
                    "invalidProp": "value"
                }
            }
        }`;

        auto json = parseJSON(jsonString);
        auto style = Style.parse(json["testStyle"], "testStyle");
    }
    catch (Exception e)
    {
        exceptionThrown = true;
    }
    assert(exceptionThrown);
}