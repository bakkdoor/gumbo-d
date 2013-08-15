module gumbo.node;

import gumbo.capi;

import std.conv : text;
import std.stdio;

class Node {
    enum Type {
        DOCUMENT,
        ELEMENT,
        TEXT,
        CDATA,
        COMMENT,
        WHITESPACE
    };

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

        switch(cast(Type)node.type) {
            case Type.DOCUMENT:
            return new Document(node);
            case Type.ELEMENT:
            return new Element(node);
            case Type.TEXT:
            return new Text(node);
            case Type.CDATA:
            return new Text(node);
            case Type.COMMENT:
            return new Text(node);
            case Type.WHITESPACE:
            return new Text(node);
            default:
            return null;
        }
    }
}

class Attribute {
private:
    GumboAttribute * _attr;

public:
    this(GumboAttribute * attr)
    {
        _attr = attr;
    }

    GumboAttributeNamespaceEnum attrNamespace()
    {
        return _attr.attr_namespace;
    }

    string name()
    {
        return text(_attr.name);
    }

    string originalName()
    {
        return text(_attr.original_name);
    }

    string value()
    {
        return text(_attr.value);
    }

    string originalValue()
    {
        return text(_attr.original_value);
    }

    GumboSourcePosition nameStart()
    {
        return _attr.name_start;
    }

    GumboSourcePosition nameEnd()
    {
        return _attr.name_end;
    }

    GumboSourcePosition valueStart()
    {
        return _attr.value_start;
    }

    GumboSourcePosition valueEnd()
    {
        return _attr.value_end;
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
    enum Tag {
        HTML, HEAD, TITLE, BASE, LINK, META, STYLE, SCRIPT, NOSCRIPT, BODY,
        SECTION, NAV, ARTICLE, ASIDE, H1, H2, H3, H4, H5, H6, HGROUP, HEADER,
        FOOTER, ADDRESS, P, HR, PRE, BLOCKQUOTE, OL, UL, LI, DL, DT, DD,
        FIGURE, FIGCAPTION, DIV, A, EM, STRONG, SMALL, S, CITE, Q, DFN, ABBR,
        TIME, CODE, VAR, SAMP, KBD, SUB, SUP, I, B, MARK, RUBY, RT, RP, BDI,
        BDO, SPAN, BR, WBR, INS, DEL, IMAGE, IMG, IFRAME, EMBED, OBJECT, PARAM,
        VIDEO, AUDIO, SOURCE, TRACK, CANVAS, MAP, AREA, MATH, MI, MO, MN, MS,
        MTEXT, MGLYPH, MALIGNMARK, ANNOTATION_XML, SVG, FOREIGNOBJECT, DESC,
        TABLE, CAPTION, COLGROUP, COL, TBODY, THEAD, TFOOT, TR, TD, TH, FORM,
        FIELDSET, LEGEND, LABEL, INPUT, BUTTON, SELECT, DATALIST, OPTGROUP,
        OPTION, TEXTAREA, KEYGEN, OUTPUT, PROGRESS, METER, DETAILS, SUMMARY,
        COMMAND, MENU, APPLET, ACRONYM, BGSOUND, DIR, FRAME, FRAMESET,
        NOFRAMES, ISINDEX, LISTING, XMP, NEXTID, NOEMBED, PLAINTEXT, RB,
        STRIKE, BASEFONT, BIG, BLINK, CENTER, FONT, MARQUEE, MULTICOL, NOBR,
        SPACER, TT, U, UNKNOWN, LAST,
    };

    GumboElement * _element;

    Node[] _children;
    Attribute[string] _attributes;

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
            Attribute attr = new Attribute(cast(GumboAttribute*)_element.attributes.data[i]);
            _attributes[attr.name()] = attr;
        }
    }

    Node[] children()
    {
        return _children;
    }

    Attribute[string] attributes()
    {
        return _attributes;
    }

    Attribute getAttribute(string name) {
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
