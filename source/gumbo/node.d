module gumbo.node;

import gumbo.capi;

import std.conv : text;
import std.stdio;

class Node {
private:
    GumboNode * _node;
    //Node _parent;

public:
    this(GumboNode * node)
    {
        _node = node;
        //_parent = Node.fromCAPI(node.parent);
    }

    GumboNodeType type()
    {
        return _node.type;
    }

    size_t indexWithinParent()
    {
        return _node.index_within_parent;
    }

    GumboParseFlags parseFlags()
    {
        return _node.parse_flags;
    }

    static Node fromCAPI(GumboNode * node)
    {
        if(!node)
            return null;

        switch(node.type) {
            case GumboNodeType.GUMBO_NODE_DOCUMENT:
                return new Document(node);
            case GumboNodeType.GUMBO_NODE_ELEMENT:
                return new Element(node);
            case GumboNodeType.GUMBO_NODE_TEXT:
                return new Text(node);
            case GumboNodeType.GUMBO_NODE_CDATA:
                return new Text(node);
            case GumboNodeType.GUMBO_NODE_COMMENT:
                return new Text(node);
            case GumboNodeType.GUMBO_NODE_WHITESPACE:
                return new Text(node);
            default:
                return null;
        }
    }
}

class Document : Node {
private:
    GumboDocument * _doc;

    Node[] _children;

    string _name;
    string _publicIdentifier;
    string _systemIdentifier;

public:
    this(GumboNode * node)
    {
        super(node);

        _doc = &node.v.document;

        for(uint i = 0; i < _doc.children.length; i++) {
            _children ~= Node.fromCAPI(cast(GumboNode*)_doc.children.data[i]);
        }

        _name = text(_doc.name);
        _publicIdentifier = text(_doc.public_identifier);
        _systemIdentifier = text(_doc.system_identifier);
    }

    Node[] children()
    {
        return _children;
    }

    bool hasDoctype()
    {
        return _doc.has_doctype;
    }

    string name()
    {
        return _name;
    }

    string publicIdentifier()
    {
        return _publicIdentifier;
    }

    string systemIdentifier()
    {
        return _systemIdentifier;
    }

    GumboQuirksModeEnum docTypeQuirksMode()
    {
        return _doc.doc_type_quirks_mode;
    }
}

class Element : Node {
    GumboElement * _element;

    Node[] _children;
    GumboAttribute*[string] _attributes;

public:
    this(GumboNode * node)
    {
        super(node);
        _element = &node.v.element;

        for(uint i = 0; i < _element.children.length; i++) {
            GumboNode * child = cast(GumboNode*)_element.children.data[i];
            _children ~= Node.fromCAPI(child);
        }


        for(uint i = 0; i < _element.attributes.length; i++) {
            GumboAttribute * attr = cast(GumboAttribute*)_element.attributes.data[i];
            _attributes[text(attr.name)] = attr;
        }
    }

    Node[] children()
    {
        return _children;
    }

    GumboAttribute*[string] attributes()
    {
        return _attributes;
    }

    GumboAttribute* getAttribute(string name) {
        if(name in _attributes)
            return _attributes[name];
        return null;
    }

    GumboTag tag()
    {
        return _element.tag;
    }

    GumboNamespaceEnum tagNamespace()
    {
        return _element.tag_namespace;
    }

    GumboStringPiece originalTag()
    {
        return _element.original_tag;
    }

    GumboStringPiece originalEndTag()
    {
        return _element.original_end_tag;
    }

    GumboSourcePosition startPos()
    {
        return _element.start_pos;
    }

    GumboSourcePosition endPos()
    {
        return _element.end_pos;
    }

}

class Text : Node {
    GumboText * _gtext;
    string _text;

public:
    this(GumboNode * node)
    {
        super(node);

        _gtext = &node.v.text;
        _text = text(_gtext.text);
    }

    GumboStringPiece originalText()
    {
        return _gtext.original_text;
    }

    GumboSourcePosition startPos()
    {
        return _gtext.start_pos;
    }
}
