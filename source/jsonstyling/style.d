module jsonstyling.style;

import std.format;
import std.typecons;
import std.algorithm;

import jsonstyling.property;
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

    private static class StyleBuilder
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

    private static class StateStyleBulder : StyleBuilder
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
}