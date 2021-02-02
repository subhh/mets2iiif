METS2IIIF
=

About
-

A Java JAX-RS web application that converts a digital object description from
[METS](https://www.loc.gov/standards/mets/) to a [IIIF Presentation API v2](https://iiif.io/api/presentation/2.1/)
manifest. It requires a METS that adheres to the [METS application profile for digitization
projects](http://dfg-viewer.de/profil-der-metadaten/) by the german national research foundation ([Deutsche
Forschungsgemeinschaft](https://dfg.de), DFG).

This application evolved from a [PHP web application](https://github.com/dmj/diglib-iiif) developed for the [HAB
Wolfenbüttel](https://www.hab.de) and [Bodleian Libraries](https://www.bodleian.ox.ac.uk) joint project [Manuscripts
from German-Speaking Lands – A Polonsky Foundation Digitization Project](https://hab.bodleian.ox.ac.uk) (2019–2021).

Concept
-

The application does not provide an in-memory representation of the IIIF entities but uses XSL transformation to
retrieve the requested information from the METS file. This operation is based on the isomorphism of a METS document and
the IIIF manifest.

License
-

IIIF Presentation is released under the terms of the MIT license.

Authors
-

David Maus &lt;david.maus@sub.uni-hamburg.de&gt;
