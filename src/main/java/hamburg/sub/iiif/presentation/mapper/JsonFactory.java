/*
 * Copyright (C) 2020,2021 by Staats- und Universitätsbibliothek Hamburg
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package hamburg.sub.iiif.presentation.mapper;

import javax.json.JsonBuilderFactory;
import javax.json.JsonArrayBuilder;
import javax.json.JsonObjectBuilder;
import javax.json.JsonNumber;
import javax.json.Json;

import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import java.util.List;
import java.util.ArrayList;

import java.util.logging.Logger;

import net.jcip.annotations.ThreadSafe;

/**
 * Serialize JSON XML to JSON.
 *
 * <p>Given a JSON map in the canonical XML representation as defined in [XSLT3], return a JsonObjectBuilder that returns
 * the corresponding JSON representation.</p>
 *
 * <p>This class DOES NOT implement a generic conversion from the JSON XML representation to native JSON.</p>
 *
 * <p>[XSLT3] https://www.w3.org/TR/xslt-30/</p>
 *
 */
@ThreadSafe
class JsonFactory
{
    private static final Logger LOG = Logger.getLogger(JsonFactory.class.getName());

    private static final String MESSAGE_UNKNOWN_ELEMENT = "Unknown element(%s)";

    private static final String JSON_NAMESPACE_URI = "http://www.w3.org/2005/xpath-functions";
    private static final String JSON_MAP = "map";
    private static final String JSON_KEY = "key";
    private static final String JSON_STRING = "string";
    private static final String JSON_ARRAY = "array";
    private static final String JSON_NUMBER = "number";
    private static final String JSON_NULL = "null";
    private static final String JSON_BOOLEAN = "boolean";

    private final JsonBuilderFactory jsonBuilderFactory;

    JsonFactory ()
    {
        this(Json.createBuilderFactory(null));
    }

    JsonFactory (final JsonBuilderFactory jsonBuilderFactory)
    {
        this.jsonBuilderFactory = jsonBuilderFactory;
    }

    JsonObjectBuilder createJsonObject (final Element element)
    {
        if (!element.getNamespaceURI().equals(JSON_NAMESPACE_URI) || !element.getLocalName().equals(JSON_MAP)) {
            String message = String.format("Expected argument to be element(Q{http://www.w3.org/2005/xpath-functions}map), got %s", createEQName(element));
            throw new IllegalArgumentException(message);
        }

        JsonObjectBuilder builder = jsonBuilderFactory.createObjectBuilder();
        List<Element> children = getChildElements(element);
        for (int i = 0; i < children.size(); i++) {
            Element child = children.get(i);
            if (child.hasAttribute(JSON_KEY)) {
                String key = child.getAttribute(JSON_KEY);
                switch (child.getLocalName()) {
                case JSON_STRING:
                    builder.add(key, Json.createValue(child.getTextContent()));
                    break;
                case JSON_NUMBER:
                    builder.add(key, createNumber(child.getTextContent()));
                    break;
                case JSON_ARRAY:
                    builder.add(key, createJsonArray(child));
                    break;
                case JSON_MAP:
                    builder.add(key, createJsonObject(child));
                    break;
                case JSON_NULL:
                    builder.addNull(key);
                    break;
                case JSON_BOOLEAN:
                    builder.add(key, Boolean.parseBoolean(child.getTextContent()));
                    break;
                default:
                    String message = String.format(MESSAGE_UNKNOWN_ELEMENT, createEQName(child));
                    LOG.info(message);
                }
            } else {
                String message = String.format("Element %s is missing required attribute(Q{}key)", createEQName(child));
                LOG.info(message);
            }
        }

        return builder;
    }

    JsonArrayBuilder createJsonArray (final Element element)
    {
        if (!element.getNamespaceURI().equals(JSON_NAMESPACE_URI) || !element.getLocalName().equals(JSON_ARRAY)) {
            String message = String.format("Expected argument to be element(Q{http://www.w3.org/2005/xpath-functions}array), got %s", createEQName(element));
            throw new IllegalArgumentException(message);
        }

        JsonArrayBuilder builder = jsonBuilderFactory.createArrayBuilder();
        List<Element> children = getChildElements(element);
        for (int i = 0; i < children.size(); i++) {
            Element child = children.get(i);
            switch (child.getLocalName()) {
            case JSON_STRING:
                builder.add(Json.createValue(child.getTextContent()));
                break;
            case JSON_NUMBER:
                builder.add(createNumber(child.getTextContent()));
                break;
            case JSON_ARRAY:
                builder.add(createJsonArray(child));
                break;
            case JSON_MAP:
                builder.add(createJsonObject(child));
                break;
            case JSON_NULL:
                builder.addNull();
                break;
            case JSON_BOOLEAN:
                builder.add(Boolean.parseBoolean(child.getTextContent()));
                break;
            default:
                String message = String.format(MESSAGE_UNKNOWN_ELEMENT, createEQName(child));
                LOG.info(message);
            }
        }
        return builder;
    }

    JsonNumber createNumber (final String textvalue)
    {
        if (textvalue.matches("^[0-9]+$")) {
            return Json.createValue(Integer.parseInt(textvalue));
        } else {
            return Json.createValue(Double.parseDouble(textvalue));
        }
    }

    List<Element> getChildElements (final Element parent)
    {
        List<Element> children = new ArrayList<Element>();
        NodeList nodes = parent.getChildNodes();
        for (int i = 0; i < nodes.getLength(); i++) {
            if (Node.ELEMENT_NODE == nodes.item(i).getNodeType()) {
                Element child = (Element)nodes.item(i);
                if (child.getNamespaceURI().equals(JSON_NAMESPACE_URI)) {
                    children.add(child);
                } else {
                    String message = String.format("Unexpected child element(%s) at position %d", createEQName(child), i);
                    LOG.info(message);
                }
            }
        }
        return children;
    }

    String createEQName (final Element element)
    {
        return String.format("Q{%s}%s", element.getNamespaceURI(), element.getLocalName());
    }
}
