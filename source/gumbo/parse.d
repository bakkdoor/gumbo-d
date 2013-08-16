module gumbo.parse;

import gumbo.capi;
import gumbo.node;
import std.string : toStringz;
import std.file : readText;

class Output {
private:
    GumboOutput* _output;
    Node _root;

public:
    this(GumboOutput* output)
    {
        _output = output;
        _root = Node.fromCAPI(_output.root);
    }

    Node root() {
        return _root;
    }

    void destroy(const(GumboOptions)* options = &kGumboDefaultOptions)
    {
        gumbo_destroy_output(options, _output);
    }

    static Output fromFile(string filename)
    {
        return fromString(readText(filename));
    }

    static Output fromString(string str)
    {
        GumboOutput *output = gumbo_parse(toStringz(str));
        return new Output(output);
    }
}
