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

package hamburg.sub.iiif.presentation;

import java.io.InputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

import javax.json.JsonObjectBuilder;
import javax.ws.rs.GET;
import javax.ws.rs.OPTIONS;

import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;

import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.ResponseBuilder;
import javax.ws.rs.core.Response.Status;

import hamburg.sub.iiif.presentation.mapper.CollectionNotFoundException;
import hamburg.sub.iiif.presentation.mapper.CollectionProvider;
import net.jcip.annotations.ThreadSafe;

/**
 * IIIF Presentation collection API.
 */
@ThreadSafe
@Path("collection")
public final class Collection
{
    private final CollectionProvider collections = new CollectionProvider();

    @OPTIONS
    @Path("all")
    public Response getCollectionCORS ()
    {
        return Response.noContent().build();
    }

    @GET
    @Path("all")
    @Produces({"application/ld+json", "application/json"})
    public Response getCollection ()
    {
        return getCollectionResponse(null);
    }

    @GET
    @Path("all/{page : [0-9]+}")
    @Produces({"application/ld+json", "application/json"})
    public Response getCollection (@PathParam("page") final Integer page)
    {
        return getCollectionResponse(page);
    }

    @OPTIONS
    public Response getToplevelCollectionCORS ()
    {
        return Response.noContent().build();
    }

    @GET
    @Produces({"application/ld+json", "application/json"})
    public Response getToplevelCollection ()
    {
        InputStream resource = getClass().getResourceAsStream("/collection.json");
        ByteArrayOutputStream data = new ByteArrayOutputStream();

        try {
            int chr;
            do {
                chr = resource.read();
                if (chr != -1) {
                    data.write(chr);
                }
            } while (chr != -1);
            return Response.ok(data.toByteArray()).build();
        } catch (IOException e) {
            throw new RuntimeException(e);
        } finally {
            try {
                if (resource != null) {
                    resource.close();
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }

    private Response getCollectionResponse (final Integer page)
    {
        ResponseBuilder response;
        try {
            JsonObjectBuilder collection = collections.getCollection(page);
            response = Response.ok(collection.build().toString());
        } catch (CollectionNotFoundException | IOException e) {
            response = Response.status(Status.NOT_FOUND);
        }
        return response.build();
    }
}
