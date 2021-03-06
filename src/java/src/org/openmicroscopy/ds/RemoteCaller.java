/*
 * org.openmicroscopy.ds.RemoteCaller
 *
 *------------------------------------------------------------------------------
 *
 *  Copyright (C) 2003 Open Microscopy Environment
 *      Massachusetts Institute of Technology,
 *      National Institutes of Health,
 *      University of Dundee
 *
 *
 *
 *    This library is free software; you can redistribute it and/or
 *    modify it under the terms of the GNU Lesser General Public
 *    License as published by the Free Software Foundation; either
 *    version 2.1 of the License, or (at your option) any later version.
 *
 *    This library is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    Lesser General Public License for more details.
 *
 *    You should have received a copy of the GNU Lesser General Public
 *    License along with this library; if not, write to the Free Software
 *    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *------------------------------------------------------------------------------
 */


/*------------------------------------------------------------------------------
 * Written by:    Douglas Creager <dcreager@alum.mit.edu>
 *------------------------------------------------------------------------------
 */


package org.openmicroscopy.ds;

/**
 * Provides an interface for making generic RPC calls.  Currently, the
 * only implementation of this interface is the {@link XmlRpcCaller}
 * class.  If, at some point in the future, the transport protocol of
 * the remote framework changes, that should be the only class which
 * needs rewriting.
 *
 * @author Douglas Creager (dcreager@alum.mit.edu)
 * @version 2.2 <small><i>(Internal: $Revision$ $Date$)</i></small>
 * @since OME2.2
 */

public interface RemoteCaller
    extends DataService
{
    void login(String username, String password);

    void logout();

    String getSessionKey();

    /**
     * Allows an existing connection to be reauthenticated.  Returns true if
     * successful, or false if the session key is invalid.
     */
    boolean authenticate();

    /**
     * Sets the session key directly to a known key string.
     * No verification or error checking is performed on the key.
     */
    void setSessionKey(String key);

    /**
     * Returns the version of the server which this
     * <code>RemoteCaller</code> is connected to.  The {@link
     * ServerVersion} class can be used to compare two versions,
     * allowing clients to check for compatible server versions.
     */
    ServerVersion getServerVersion();

    /**
     * Invoke an arbitrary remote procedure.
     */
    Object invoke(String procedure, Object[] params);

    /**
     * Invoke a remote method via the <code>dispatch</code> procedure.
     * The method can receive an arbitrary number of parameters.
     */
    Object dispatch(String method, Object[] params);

    /**
     * Invoke a remote method via the <code>dispatch</code> procedure.
     * The method can receive an arbitrary number of parameters.  The
     * method is expected to return a result which can be somehow
     * typecast into an {@link Integer}.  If it can't, a {@link
     * RemoteServerErrorException} is thrown.
     */
    Integer dispatchInteger(String method, Object[] params);

    void startProfiler();
    void stopProfiler();
    void resetProfiler();
    long getProfiledMilliseconds();
}
