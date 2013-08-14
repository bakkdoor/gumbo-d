import gumbo;

import std.stdio, std.file;
import std.string : toStringz;
import std.conv : text;

string[] find_links(GumboNode* node) {
    string[] links;

    if (node.type != GumboNodeType.GUMBO_NODE_ELEMENT) {
        return links;
    }

    GumboAttribute* href;
    if (node.v.element.tag == GumboTag.GUMBO_TAG_A) {
        href = gumbo_get_attribute(&node.v.element.attributes, "href");
        if(href) {
            links ~= text(href.value);
        }
    }

    GumboVector* children = &node.v.element.children;
    for (int i = 0; i < children.length; ++i) {
        links ~= find_links(cast(GumboNode*) children.data[i]);
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

    string contents = readText(filename);

    GumboOutput* output = gumbo_parse(toStringz(contents));
    foreach(link; find_links(output.root)) {
        writeln(link);
    }
    gumbo_destroy_output(&kGumboDefaultOptions, output);

    return 0;
}
