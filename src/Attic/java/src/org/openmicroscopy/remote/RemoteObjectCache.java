/*
 * org.openmicroscopy.remote.RemoteObjectCache
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
 *
 * Written by:    Douglas Creager <dcreager@alum.mit.edu>
 *
 *------------------------------------------------------------------------------
 */




package org.openmicroscopy.remote;

import java.lang.ref.WeakReference;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.Map;
import java.util.HashMap;
import java.io.*;


/**
 * <p>Maintains a cache of remote objects returned over an XML-RPC
 * connection.  There is one <code>RemoteObjectCache</code> per OME
 * session.</p>
 *
 * <p>The <code>RemoteObjectCache</code> is the second of two caches
 * that exist along the XML-RPC call chain.  The first is the cache on
 * the server side.  The rules for the caches are as follows:</p>
 *
 * <ol>
 *
 * <li>All remote objects are created on the Perl side.  They are
 * realized on the Java side only when they are seen as a return value
 * from a remote method.</li>
 *
 * <li>All objects created on the Perl side are stored in the Perl
 * cache until one of two events takes place:
 *
 * <ol>
 *
 * <li>The client specifically asks for the object to be removed from
 * the cache via a call to the remote <code>freeObject</code>
 * procedure.</li>
 *
 * <li>The session is actively closed via a call to the remote
 * <code>closeSession</code> procedure.</li>
 *
 * </ol></li>
 *
 * <li>If a Perl object, after having been removed from the Perl
 * cache, is returned again from a remote method call, it is placed
 * back into the hash.</li>
 *
 * <li>At most one Java object is created for each remote object
 * reference received over the XML-RPC connection.  When created, this
 * object is stored in the Java cache.  This allows subsequent
 * references to the same remote object to be returned as the same
 * Java object.</li>
 *
 * <li>All Java objects are stored in the Java cache as weak
 * references.  This allows the garbage collector to correctly
 * determine when Java objects are no longer in scope.</li>
 *
 * <li>When a Java object falls out of scope, the garbage collector
 * removes it from both caches by calling the object's {@link
 * #finalize} method.  The object is removed from the Perl cache via a
 * call to the remote <code>freeObject</code> method.</li>
 *
 * </ol>
 *
 * <p>Note that this class does not cache the fields of a Java object.
 * There is a per-object cache for this purpose.  This class caches
 * the objects themselves.  In the case of a field which is a
 * reference to another object, the per-object cache stores the
 * reference, and uses the <code>RemoteObjectCache</code> to get a
 * Java code corresponding to that reference.</p>
 *
 * @author Douglas Creager
 * @version 2.0
 * @since OME2.0
 * @see RemoteObject
 */

public class RemoteObjectCache
    implements RemoteConstants
{
    public static boolean TRACE_CACHE = false;

    private File  traceFilename;
    private PrintWriter  traceFile;

    /**
     * The session that this cache belongs to.
     */
    protected RemoteSession  session;

    /**
     * The actual object cache.  Maps remote object references (which
     * are Strings) to {@link WeakReference WeakReferences} to {@link
     * RemoteObject RemoteObjects}.
     */
    protected Map            objectCache;

    /**
     * Creates a new instance for the given session.
     * @param session the session that this cache belongs to
     */
    public RemoteObjectCache(RemoteSession session)
    {
        this.session = session;
        this.objectCache = new HashMap();

        if (TRACE_CACHE)
        {
            try
            {
                traceFilename = File.createTempFile("cache-",".txt");
                traceFile = new PrintWriter(
                    new BufferedWriter(new FileWriter(traceFilename)),
                    true);
                System.err.println("Using trace file "+traceFilename);
            } catch (IOException e) {
                System.err.println("Could not create trace file!");
            }
            traceFile.println("Time\tReference\tClass\tCalling class\tCalling method\tLine");
        }

    }

    public void closeTrace()
    {
        if (traceFile != null)
        {
            traceFile.close();
            traceFile = null;
        }
    }

    private void printTrace(String reference, String clazz)
    {
        if (traceFile != null)
        {
            StackTraceElement[] stackTrace = null;
            try
            {
                throw new Exception();
            } catch (Exception e) {
                stackTrace = e.getStackTrace();
            }

            int i = 3;
            if (i >= stackTrace.length) i = stackTrace.length;

            if (stackTrace[i].getMethodName().equals("main")) i--;

            int pos = clazz.lastIndexOf('.');
            if (pos >= 0) clazz = clazz.substring(pos+1);

            String callClazz = stackTrace[i].getClassName();
            pos = callClazz.lastIndexOf('.');
            if (pos >= 0) callClazz = callClazz.substring(pos+1);

            traceFile.println(System.currentTimeMillis()+"\t"+
                              reference+"\t"+clazz+"\t"+
                              callClazz+"\t"+
                              stackTrace[i].getMethodName()+"\t"+
                              stackTrace[i].getLineNumber());
        }
    }

    /**
     * Determines which Java classes are used to represent each Perl
     * class.  Used by the {@link #getObject} method to create objects
     * of the appropriate class when an object isn't in the cache.
     * The Perl class to instantiate is defined by the prototype of
     * the method.
     */
    protected static Map classes = new HashMap();

    /**
     * Associates the Perl class <code>className</code> with the Java
     * class <code>clazz</code>.  If the Perl class is already
     * associated with a Java class, this association is overwritten.
     * @param className the name of the Perl class
     * @param clazz the {@link Class} object of the Java class
     */
    public static void addClass(String className, Class clazz)
    { classes.put(className,clazz); }

    /**
     * Returns the Java class which is associated with the given Perl
     * class.  This association must have been previously established
     * by the {@link #addClass} method.
     * @param className the name of the Perl class
     * @return the {@link Class} object of the associated Java class
     */
    public static Class getClass(String className)
    { return (Class) classes.get(className); }

    public void clearCache()
    {
        objectCache.clear();
    }

    /**
     * Returns a {@link RemoteObject} for the given Perl class and
     * reference.  It determines which Java class to instantiate by
     * calling the {@link #getClass(String)} method.
     * @param perlClass the Perl class to instantiate
     * @param reference the remote object reference
     */
    public RemoteObject getObject(String perlClass, String reference)
    {
        Class clazz = getClass(perlClass);

        if (clazz == null)
            throw new IllegalArgumentException("Cannot find class!");

        if ((reference != null) && (!reference.equals("")))
        {
            if (reference.equals(NULL_REFERENCE))
            {
                if (TRACE_CACHE)
                    printTrace("Null","null");
                return null;
            }

            RemoteObject  newObj;
            WeakReference objRef;

            objRef = (WeakReference) objectCache.get(reference);

            // If we find a weak reference, ....
            if (objRef != null)
            {
                newObj = (RemoteObject) objRef.get();

                // ...and the object it points to is still valid,
                // return that object.
                if (newObj != null)
                {
                    if (TRACE_CACHE)
                        printTrace(reference,newObj.getClass().getName());
                    return newObj;
                }
            }

            // If we are here, then either there was no reference in
            // the cache, or the object that the reference points to
            // is no longer valid.
            try
            {
                // Before, we were instantiating the object via the
                // no-argument constructor, and then filling in the
                // session and reference via mutator calls.  However,
                // this meant that the constructors could not access
                // any of the object's state, since the appropriate
                // remote calls could not be synthesized without the
                // reference.  Now, we instantiate via the
                // two-argument constructor, which allows these remote
                // calls to be made.

                Constructor  cons = clazz.getConstructor(new Class[]
                    {
                        RemoteSession.class,
                        String.class
                    });

                newObj = (RemoteObject) cons.newInstance(new Object[]
                    {
                        session,
                        reference
                    });
            } catch (NoSuchMethodException e) {
                System.err.println(e);
                return null;
            } catch (InstantiationException e) {
                System.err.println(e);
                return null;
            } catch (IllegalAccessException e) {
                System.err.println(e);
                return null;
            } catch (IllegalArgumentException e) {
                System.err.println(e);
                return null;
            } catch (InvocationTargetException e) {
                System.err.println(e);
                return null;
            }

            objectCache.put(reference,new WeakReference(newObj));

            if (TRACE_CACHE)
                printTrace(reference,newObj.getClass().getName());
            return newObj;
        } else {
            if (TRACE_CACHE)
                printTrace("Null","null");
            return null;
        }        
    }
}
