import gumbo.node, gumbo.parse;
import std.stdio;

string[] findLinks(Node root)
{
    string[] links;

    foreach(link; root.findChildren!Element(e => e.tag == Element.Tag.a)) {
        if(auto href = link.getAttribute("href"))
            links ~= href.value;
    }

    return links;
}

void usage() {
    stderr.writeln("Usage: find_links <html filename>");
}

int main(string[] argv) {
    if (argv.length != 2) {
        usage();
        return 1;
    }

    string filename = argv[1];

    scope(failure) {
        stderr.writeln("Error: ", filename, " is not a file");
        usage();
        return 1;
    }

    auto output = gumbo.parse.Output.fromFile(filename);
    foreach(link; findLinks(output.root)) {
        writeln(link);
    }
    output.destroy();

    return 0;
}
