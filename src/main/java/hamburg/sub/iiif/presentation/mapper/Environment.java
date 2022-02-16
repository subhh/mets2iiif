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

import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import net.jcip.annotations.ThreadSafe;

/**
 * A bridge to the digital library environment.
 */
@ThreadSafe
public final class Environment
{
    private final String solrBaseUrl;

    public Environment ()
    {
        solrBaseUrl = System.getProperty("hamburg.sub.iiif.presentation.solr.baseUrl");
    }

    public URL resolveEntitySourceUrl (final String objectId) throws MalformedURLException
    {
        return new URL("http://mets.sub.uni-hamburg.de/kitodo/" + objectId);
    }

    public URL resolveCollectionSourceUrl (final int page) throws MalformedURLException
    {
        if (solrBaseUrl == null) {
            String filename;
            if (page == 0) {
                filename = "/collection-0.xml";
            } else {
                filename = "/collection-1.xml";
            }
            return getClass().getResource(filename);
        }

        return new URL(solrBaseUrl);
    }

    private String encode (final String value)
    {
        try {
            return URLEncoder.encode(value, StandardCharsets.UTF_8.toString());
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException(e);
        }
    }
}
