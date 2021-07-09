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

import javax.json.JsonObjectBuilder;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;

import javax.xml.transform.stream.StreamSource;

import javax.xml.transform.dom.DOMResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import java.net.URL;

import java.io.IOException;

import net.jcip.annotations.ThreadSafe;

/**
 * Retrieves entities via XSL transformation.
 */
@ThreadSafe
public final class EntityProvider
{
    private final JsonFactory jsonFactory = new JsonFactory();
    private final TransformerProvider transformerProvider = new TransformerProvider();
    private final Environment environment = new Environment();

    public JsonObjectBuilder getEntity (final String objectId, final EntityType entityType, final String entityId) throws IOException, EntityNotFoundException
    {
        URL sourceUrl = environment.resolveSourceUrl(objectId);

        Source source = new StreamSource(sourceUrl.openStream());
        Element entityElement = getEntityElement(source, entityType, entityId);
        return jsonFactory.createJsonObject(entityElement);
    }

    private Element getEntityElement (final Source source, final EntityType entityType, final String entityId) throws EntityNotFoundException
    {
        Transformer transformer = transformerProvider.newTransformer();

        DOMResult result = new DOMResult();
        try {
            transformer.clearParameters();
            transformer.setParameter("entityType", entityType);
            if (entityId != null) {
                transformer.setParameter("entityId", entityId);
            }
            transformer.transform(source, result);
        } catch (TransformerException e) {
            String message = String.format("Transformation error while getting entity %s with id %s", entityType, entityId);
            throw new RuntimeException(message, e);
        }
        Element entity = ((Document)result.getNode()).getDocumentElement();
        if (entity.getLocalName().equals("error")) {
            throw new EntityNotFoundException(entity.getTextContent());
        }
        return entity;
    }
}
