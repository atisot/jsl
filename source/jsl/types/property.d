module jsl.types.property;

import std.conv;
import std.traits;

interface IProperty
{
    string toString() const;
}

class Property(T) : IProperty
{
    private T value;

    this(T newValue)
    {
        value = newValue;
    }

    T get()
    {
        return value;
    }

    override string toString() const
    {
        static if (__traits(compiles, { string s = value.toString(); }))
        {
            return value.toString();
        }
        else
        {
            return to!string(value);
        }
    }
}