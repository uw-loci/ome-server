/*
 *------------------------------------------------------------------------------
 *
 *  Copyright (C) 2004 Open Microscopy Environment
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
package org.openmicroscopy.ds.tests;

import java.net.MalformedURLException;
import java.util.List;
import java.util.Iterator;

import org.openmicroscopy.ds.Criteria;
import org.openmicroscopy.ds.DataFactory;
import org.openmicroscopy.ds.DataServer;
import org.openmicroscopy.ds.DataServices;
import org.openmicroscopy.ds.RemoteCaller;
import org.openmicroscopy.ds.ServerVersion;
import org.openmicroscopy.ds.dto.Project;
import org.openmicroscopy.ds.dto.Dataset;


/**
 * 
 *  A test program for evaluating the performance of OME-JAVA performance on 
 * retrieving modules.
 * @author <br>Harry Hochheiser &nbsp;&nbsp;&nbsp;
 * 	<A HREF="mailto:hsh@nih.gov">hsh@nih.gov</A>
 *
 *  @version 2.2
 * <small>
 * </small>
 * @since OME2.2
 */
public class ProjectTest {

	/** 
	 * Update the following variables as appropriate for your local installation.
	 */
	private static final String SHOOLA_URL="http://127.0.0.1:8000/shoolasoap"; 
	private static final String USER ="hsh";
	private static final String PASS = "foobar";
	
	private DataServices services;
	private DataFactory factory;
	
	public ProjectTest() {
		super();
		
		try {
			// construct connection to omeds
			services = DataServer.getDefaultServices(SHOOLA_URL);
			// doe the basic login
			initializeFactory(services);
			if (factory == null) {
				System.err.println("Cannot contact Shoola server: "+SHOOLA_URL);
				System.exit(0);
			}
			getProjects();
			System.err.println("Done!");
		}
		catch (MalformedURLException e) {
			System.err.println("Improperly specified Shoola URL: "+SHOOLA_URL);
			System.exit(0);
		}	
	}
	
	
	private void initializeFactory(DataServices services) {
		System.err.println("trying to get data...");
		//  login 
		RemoteCaller remote = services.getRemoteCaller();
		remote.login(USER,PASS);
		// test with server version
		ServerVersion ver = remote.getServerVersion();
		System.err.println("Server Version "+ ver);
		
		// retrieve the DataFactory which is used for data requests
		factory =  (DataFactory) services.getService(DataFactory.class);
	}
	
	
	private void getProjects() {
		System.err.println("\n\nOME-JAVA Test: Project Retrieval");
		System.err.println("========================================");
		
		Criteria c = getProjectsCriteria();
		List projects = factory.retrieveList(Project.class,c);
		dumpProjects(projects);
	}
	
	
	private Criteria getProjectsCriteria() {
		Criteria c = new Criteria();
		//	Specify which fields we want for the chain.
//		Specify which fields we want for the project.
		c.addWantedField("id");
		c.addWantedField("name");
		c.addWantedField("description");
		c.addWantedField("datasets");
		c.addWantedField("datasets","id");
		c.addWantedField("datasets","name");
		c.addWantedField("datasets","description");
		
		return c;
	}
    

    private static void dumpProjects(List projects) {
	Iterator iter = projects.iterator();
	while (iter.hasNext()) {
	    Project proj = (Project) iter.next();
	    System.err.println(proj.getID()+". "+proj.getName()+", "+
			       proj.getDescription());
	    List ds = proj.getDatasets();
	    if (ds != null && ds.size () > 0) {
		System.err.println("datasets...");
		dumpDatasets(ds);
	    }
	}
    }

    private static void dumpDatasets(List datasets) {
	Iterator iter = datasets.iterator();
	while (iter.hasNext()) {
	    Dataset ds = (Dataset) iter.next();
	    System.err.println("\t"+ds.getID()+". "+ds.getName()+", "+
			       ds.getDescription());

	}
    }
	
   public static void main(String[] args) {
		new ProjectTest();
	}
}
