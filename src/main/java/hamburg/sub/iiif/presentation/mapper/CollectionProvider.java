/*
 * Copyright (C) 2020-2022 by Staats- und Universitätsbibliothek Hamburg
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

import java.io.IOException;
import java.net.URL;

import javax.json.JsonObjectBuilder;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.stream.StreamSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import net.jcip.annotations.ThreadSafe;

/**
 * Provide collections.
 */
@ThreadSafe
public final class CollectionProvider
{
    private static final int ITEMS_PER_PAGE = 25;

    private final Environment environment = new Environment();
    private final JsonFactory jsonFactory = new JsonFactory();
    private final TransformerProvider transformerProvider = new TransformerProvider("/collection.xsl");

    public JsonObjectBuilder getCollection (final int page) throws CollectionNotFoundException, IOException
    {
        URL sourceUrl = environment.resolveCollectionSourceUrl(page);

        Source source = new StreamSource(sourceUrl.openStream());
        Element collectionElement = getCollectionElement(source);
        return jsonFactory.createJsonObject(collectionElement);
    }

    private Element getCollectionElement (final Source source) throws CollectionNotFoundException
    {
        Transformer transformer = transformerProvider.newTransformer();

        DOMResult result = new DOMResult();
        try {
            transformer.clearParameters();
            transformer.setParameter("itemsPerPage", ITEMS_PER_PAGE);
            transformer.transform(source, result);
        } catch (TransformerException e) {
            throw new RuntimeException("Transformation error while getting collection", e);
        }

        Element collection = ((Document)result.getNode()).getDocumentElement();
        if (collection.getLocalName().equals("error")) {
            throw new CollectionNotFoundException(collection.getTextContent());
        }
        return collection;
    }
}
