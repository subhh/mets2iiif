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

import javax.xml.transform.Templates;

import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.Transformer;

import net.sf.saxon.TransformerFactoryImpl;

import net.jcip.annotations.ThreadSafe;

/**
 * Provides a prepared Transformer.
 */
@ThreadSafe
final class TransformerProvider
{
    private final Templates templates;
    private final Resolver resolver;

    TransformerProvider (final String stylesheet)
    {
        try {
            resolver = new Resolver();
            TransformerFactory factory = new TransformerFactoryImpl();
            factory.setURIResolver(resolver);
            templates = factory.newTemplates(resolver.resolve(stylesheet, null));
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }
    }

    Transformer newTransformer ()
    {
        try {
            return templates.newTransformer();
        } catch (TransformerConfigurationException e) {
            throw new RuntimeException(e);
        }
    }
}
