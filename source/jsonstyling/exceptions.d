module jsonstyling.exceptions;

import jsonstyling;

import std.exception;

class JsonStylingException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

class ThemeParseException : JsonStylingException
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}