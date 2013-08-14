import gumbo;

import std.stdio, std.file;
import std.string : toStringz;
import std.conv : text;

static void find_links(GumboNode* node) {
    if (node.type != GumboNodeType.GUMBO_NODE_ELEMENT) {
        return;
    }
    GumboAttribute* href;
    if (node.v.element.tag == GumboTag.GUMBO_TAG_A) {
        href = gumbo_get_attribute(&node.v.element.attributes, "href");
        if(href) {
            writeln(text(href.value));
        }
    }

    GumboVector* children = &node.v.element.children;
    for (int i = 0; i < children.length; ++i) {
        find_links(cast(GumboNode*) children.data[i]);
    }
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
    find_links(output.root);
    gumbo_destroy_output(&kGumboDefaultOptions, output);

    return 0;
}
