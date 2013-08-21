module gumbo.node;

import gumbo.capi;

import std.conv : text;
import std.stdio;

class Node {
    enum Type {
        document,
        element,
        text,
        cdata,
        comment,
        whitespace
    };

protected:
    GumboNode * _node;
    Node[]      _children;

public:
    this(GumboNode * node)
    {
        _node = node;
    }

    Node parent()
    {
        return Node.fromCAPI(_node.parent);
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

    Node[] children()
    {
        return _children;
    }

    T findChild(T)(bool delegate(T) predicate)
    {
        foreach(child; children) {
            T c = cast(T)child;
            if(c && predicate(c))
                return c;

            if(T innerChild = child.findChild!T(predicate))
                return innerChild;
        }
        return null;
    }

    T findChild(T)()
    {
        foreach(child; children) {
            if(T c = cast(T)child)
                return c;

            if(T innerChild = child.findChild!T)
                return innerChild;
        }
        return null;
    }

    T[] findChildren(T)(bool delegate(T) predicate)
    {
        T[] found;
        foreach(child; children) {
            T c = cast(T)child;
            if(c && predicate(c))
                found ~= c;

            found ~= child.findChildren!T(predicate);
        }
        return found;
    }

    T[] findChildren(T)()
    {
        T[] found;
        foreach(child; children) {
            if(T c = cast(T)child)
                found ~= c;

            found ~= child.findChildren!T;
        }
        return found;
    }

    T[] mapChildren(T)(T delegate(Node) fun)
    {
        T[] vals;
        foreach(child; children) {
            vals ~= fun(child);
        }
        return vals;
    }

    T[] flatMapChildren(T)(T[] delegate(Node) fun)
    {
        T[] vals;
        foreach(child; children) {
            vals ~= fun(child);
        }
        return vals;
    }

    static Node fromCAPI(GumboNode * node)
    {
        if(!node)
            return null;

        switch(cast(Type)node.type) {
            case Type.document:
                return new Document(node);
            case Type.element:
                return new Element(node);
            case Type.text:
                return new Text(node);
            case Type.cdata:
                return new Text(node);
            case Type.comment:
                return new Text(node);
            case Type.whitespace:
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
        html, head, title, base, link, meta, style, script, noscript, body_,
        section, nav, article, aside, h1, h2, h3, h4, h5, h6, hgroup, header,
        footer, address, p, hr, pre, blockquote, ol, ul, li, dl, dt, dd,
        figure, figcaption, div, a, em, strong, small, s, cite, q, dfn, abbr,
        time, code, var, samp, kbd, sub, sup, i, b, mark, ruby, rt, rp, bdi,
        bdo, span, br, wbr, ins, del, image, img, iframe, embed, object, param,
        video, audio, source, track, canvas, map, area, math, mi, mo, mn, ms,
        mtext, mglyph, malignmark, annotationXML, svg, foreignObject, desc,
        table, caption, colgroup, col, tbody, thead, tfoot, tr, td, th, form,
        fieldset, legend, label, input, button, select, datalist, optgroup,
        option, textarea, keygen, output, progress, meter, details, summary,
        command, menu, applet, acronym, bgsound, dir, frame, frameset,
        noFrames, isIndex, listing, xmp, nextId, noEmbed, plainText, rb,
        strike, baseFont, big, blink, center, font, marquee, multicol, nobr,
        spacer, tt, u, unknown, last,
    };

    GumboElement *    _element;
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

    Attribute[string] attributes()
    {
        return _attributes;
    }

    Attribute getAttribute(string name) {
        if(name in _attributes)
            return _attributes[name];
        return null;
    }

    Tag tag()
    {
        return cast(Tag)_element.tag;
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
private:
    GumboText * _gtext;
    string _text;

public:
    this(GumboNode * node)
    {
        super(node);

        _gtext = &node.v.text;
        _text = std.conv.text(_gtext.text);
    }

    string text()
    {
        return _text;
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
