import gumbo.node, gumbo.capi, gumbo.parse;

import std.stdio;

string[] find_links(gumbo.node.Node node) {
    string[] links;

    if (node.type != GumboNodeType.GUMBO_NODE_ELEMENT) {
        return links;
    }

    gumbo.node.Element element = cast(gumbo.node.Element) node;

    if (element.tag == GumboTag.GUMBO_TAG_A) {
        GumboAttribute* href = element.getAttribute("href");
        if(href) {
            links ~= text(href.value);
        }
    }

    foreach(child; element.children) {
        links ~= find_links(child);
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

    gumbo.parse.Output output = gumbo.parse.parseFile(filename);
    foreach(link; find_links(output.root)) {
        writeln(link);
    }
    output.destroy();

    return 0;
}
