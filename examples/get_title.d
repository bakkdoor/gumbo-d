import gumbo.node, gumbo.parse;
import std.stdio;

string findTitle(Node root)
{
    Element titleElem = root.findChild!(Element)(e => e.tag == Element.Tag.TITLE);
    if(!titleElem)
        return "<no title found>";

    Text title = titleElem.findChild!(Text);
    if(title)
        return title.text;
    else
        return "<empty title>";
}

void usage()
{
    stderr.writeln("Usage: get_title <html filename>");
}

int main(string[] argv)
{
    if(argv.length != 2) {
        usage();
        return 1;
    }

    string filename = argv[1];

    scope(failure) {
        stderr.writeln("File ", filename, " not found!");
        usage();
        return 1;
    }

    Output output = gumbo.parse.Output.fromFile(filename);
    writeln(findTitle(output.root));
    output.destroy();

    return 0;
}
