import gumbo.node, gumbo.parse, gumbo.capi;
import std.stdio;

string findTitle(Node root)
{
    assert(root.type == Node.Type.ELEMENT);
    return findTitle(cast(Element)root);
}

string findTitle(Element element)
{
    assert(element.children.length >= 2);

    Node head = null;

    foreach(child; element.children) {
        if(child.type == Node.Type.ELEMENT &&
            (cast(Element)child).tag == Element.Tag.HEAD) {
            head = child;
            break;
        }
    }

    assert(head !is null);

    foreach(child; (cast(Element)head).children) {
        if(child.type == Node.Type.ELEMENT) {
            Element childElement = cast(Element) child;
            if(childElement.tag == Element.Tag.TITLE) {
                if(childElement.children.length != 1) {
                    return "<empty title>";
                }

                Node titleText = childElement.children[0];
                assert(titleText.type == Node.Type.TEXT);
                return (cast(Text)titleText).text;
            }
        }
    }

    return "<no title found>";
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
    string title = findTitle(output.root);
    writeln(title);
    output.destroy();

    return 0;
}
