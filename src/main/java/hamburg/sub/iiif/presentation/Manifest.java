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

import javax.json.JsonObjectBuilder;

import javax.ws.rs.GET;
import javax.ws.rs.OPTIONS;

import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;

import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import javax.ws.rs.core.Response.ResponseBuilder;

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
        return Response.noContent().build();
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
        return Response.noContent().build();
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
        return Response.noContent().build();
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
        try {
            JsonObjectBuilder entity = getEntity(objectId, entityType, entityId);
            response = Response.ok(entity.build().toString());
        } catch (EntityNotFoundException e) {
            response = Response.status(Status.NOT_FOUND);
        } catch (IOException e) {
            response = Response.status(Status.BAD_GATEWAY);
        }
        return response.build();
    }

    private JsonObjectBuilder getEntity (final String objectId, final EntityType entityType, final String entityId) throws EntityNotFoundException, IOException
    {
        return entities.getEntity(objectId, entityType, entityId);
    }
}
