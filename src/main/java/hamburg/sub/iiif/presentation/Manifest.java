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

package hamburg.sub.iiif.presentation;

import javax.json.JsonObjectBuilder;

import javax.ws.rs.GET;
import javax.ws.rs.OPTIONS;

import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;

import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import javax.ws.rs.core.Response.ResponseBuilder;
import javax.ws.rs.core.UriInfo;
import javax.ws.rs.core.UriBuilder;

import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;

import java.io.IOException;

import hamburg.sub.iiif.presentation.mapper.EntityNotFoundException;
import hamburg.sub.iiif.presentation.mapper.EntityProvider;
import hamburg.sub.iiif.presentation.mapper.EntityType;

import net.jcip.annotations.ThreadSafe;

/**
 * Webservice servlet.
 */
@ThreadSafe
@Path("object")
public final class Manifest
{
    private final EntityProvider entities = new EntityProvider();

    @Path("{objectId}/manifest")
    @OPTIONS
    public Response getManifestCORS ()
    {
        return getPreflightResponse();
    }

    @Path("{objectId}/manifest")
    @GET
    @Produces({"application/ld+json", "application/json"})
    public Response getManifest (@PathParam("objectId") final String objectId)
    {
        return getEntityResponse(objectId, EntityType.Manifest, null);
    }

    @Path("{objectId}/sequence/{sequenceId}")
    @OPTIONS
    public Response getSequenceCORS ()
    {
        return getPreflightResponse();
    }

    @Path("{objectId}/sequence/{sequenceId}")
    @GET
    @Produces({"application/ld+json", "application/json"})
    public Response getSequence (@PathParam("objectId") final String objectId, @PathParam("sequenceId") final String sequenceId)
    {
        return getEntityResponse(objectId, EntityType.Sequence, sequenceId);
    }

    @Path("{objectId}/canvas/{canvasId}")
    @OPTIONS
    public Response getCanvasCORS ()
    {
        return getPreflightResponse();
    }

    @Path("{objectId}/canvas/{canvasId}")
    @GET
    @Produces({"application/ld+json", "application/json"})
    public Response getCanvas (@PathParam("objectId") final String objectId, @PathParam("canvasId") final String canvasId)
    {
        return getEntityResponse(objectId, EntityType.Canvas, canvasId);
    }

    private Response getEntityResponse (final String objectId, final EntityType entityType, final String entityId)
    {
        ResponseBuilder response;
        JsonObjectBuilder entity = getEntity(objectId, entityType, entityId);
        if (entity == null) {
            response = Response.status(Status.NOT_FOUND);
        } else {
            response = Response.ok(entity.build().toString());
        }
        response = injectHeaderCORS(response);
        return response.build();
    }

    private JsonObjectBuilder getEntity (final String objectId, final EntityType entityType, final String entityId)
    {
        try {
            URI manifestUri = UriBuilder.fromPath("object/{objectId}/manifest").build(objectId);
            URI baseUri = new URI("https://iiif.sub.uni-hamburg.de/");
            URL manifestUrl = baseUri.resolve(manifestUri).toURL();
            return entities.getEntity(objectId, manifestUrl, entityType, entityId);
        } catch (EntityNotFoundException | URISyntaxException | IOException e) {
            return null;
        }
    }

    private Response getPreflightResponse ()
    {
        ResponseBuilder response = Response.status(Status.NO_CONTENT);
        response = injectHeaderCORS(response);
        return response.build();
    }

    private ResponseBuilder injectHeaderCORS (final ResponseBuilder response)
    {
        response.header("Access-Control-Allow-Origin", "*");
        response.header("Access-Control-Allow-Methods", "GET, HEAD");
        return response;
    }
}
