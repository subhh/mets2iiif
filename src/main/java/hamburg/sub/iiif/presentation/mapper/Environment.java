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
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.StringJoiner;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;

import net.jcip.annotations.ThreadSafe;

/**
 * A bridge to the digital library environment.
 */
@ThreadSafe
public final class Environment
{
    private final String solrBaseUrl;
    private final String solrAuthUser;
    private final String solrAuthPass;
    private final int itemsPerPage;

    public Environment ()
    {
        solrBaseUrl = System.getProperty("hamburg.sub.iiif.presentation.solr.baseUrl");
        solrAuthUser = System.getProperty("hamburg.sub.iiif.presentation.solr.authUser");
        solrAuthPass = System.getProperty("hamburg.sub.iiif.presentation.solr.authPass");
        itemsPerPage = Integer.parseInt(System.getProperty("hamburg.sub.iiif.presentation.itemsPerPage", "25"));
    }

    public int getItemsPerPage ()
    {
        return itemsPerPage;
    }

    public Source dereferenceEntitySource (final String objectId) throws IOException
    {
        URL url = resolveEntitySourceUrl(objectId);
        return new StreamSource(url.openStream());
    }

    private URL resolveEntitySourceUrl (final String objectId) throws MalformedURLException
    {
        return new URL("https://mets.sub.uni-hamburg.de/kitodo/" + objectId);
    }

    public Source dereferenceCollectionSource (final int page) throws IOException
    {
        return dereferenceCollectionSource(page, null);
    }

    public Source dereferenceCollectionSource (final int page, final String name) throws IOException
    {
        URL url = resolveCollectionSourceUrl(page);
        URLConnection connection = url.openConnection();
        if (solrAuthUser != null && solrAuthPass != null) {
            String credentials = String.format("%s:%s", solrAuthUser, solrAuthPass);
            String auth = Base64.getEncoder().encodeToString(credentials.getBytes(StandardCharsets.UTF_8.toString()));
            connection.setRequestProperty("Authorization", "Basic " + auth);
        }
        return new StreamSource(connection.getInputStream());
    }

    private URL resolveCollectionSourceUrl (final int page) throws MalformedURLException
    {
        return resolveCollectionSourceUrl(page, null);
    }

    private URL resolveCollectionSourceUrl (final int page, final String name) throws MalformedURLException
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

        StringJoiner queryJoiner = new StringJoiner("&", "?", "");
        queryJoiner.add("wt=xml");
        queryJoiner.add("q=" + encode("*:*"));
        queryJoiner.add("fq=" + encode("iiifReference_usi:*"));
        if (name != null) {
            queryJoiner.add("fq=" + encode("collection_usi:\"" + name + "\""));
        }
        if (page == 0) {
            queryJoiner.add("rows=0");
        } else {
            queryJoiner.add(String.format("rows=%d", itemsPerPage));
            queryJoiner.add(String.format("start=%d", (page - 1) * itemsPerPage));
        }

        return new URL(solrBaseUrl + queryJoiner.toString());
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
