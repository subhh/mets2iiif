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

import java.net.MalformedURLException;
import java.net.URL;

import net.jcip.annotations.ThreadSafe;

/**
 * A bridge to the digital library environment.
 */
@ThreadSafe
public final class Environment
{
    public URL resolveEntitySourceUrl (final String objectId) throws MalformedURLException
    {
        return new URL("http://mets.sub.uni-hamburg.de/kitodo/" + objectId);
    }

    public URL resolveCollectionSourceUrl (final Integer page)
    {
        if (page == null) {
            return getClass().getResource("/collection-0.xml");
        } else {
            return getClass().getResource("/collection-1.xml");
        }
    }
}
