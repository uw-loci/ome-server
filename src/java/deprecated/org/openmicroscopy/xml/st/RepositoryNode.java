/*
 * org.openmicroscopy.xml.RepositoryNode
 *
 *-----------------------------------------------------------------------------
 *
 *  Copyright (C) 2007 Open Microscopy Environment
 *      Massachusetts Institute of Technology,
 *      National Institutes of Health,
 *      University of Dundee,
 *      University of Wisconsin-Madison
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
 *-----------------------------------------------------------------------------
 */


/*-----------------------------------------------------------------------------
 *
 * THIS IS AUTOMATICALLY GENERATED CODE.  DO NOT MODIFY.
 * Created by curtis via Xmlgen on Dec 18, 2007 12:41:44 PM CST
 *
 *-----------------------------------------------------------------------------
 */

package org.openmicroscopy.xml.st;

import java.util.List;
import ome.xml.OMEXMLNode;
import org.openmicroscopy.xml.*;
import org.openmicroscopy.ds.st.*;
import org.w3c.dom.Element;

/**
 * RepositoryNode is the node corresponding to the
 * "Repository" XML element.
 *
 * Name: Repository
 * AppliesTo: G
 * Location: OME/src/xml/OME/Core/OMEIS/Repository.ome
 * Description: Un repositorio es una porcion del sistema de archivos del
 *   servidor dedicado a OME. Esta usado primariamente para almacenar los
 *   pixeles de las imagenes de OME.
 */
public class RepositoryNode extends AttributeNode
  implements Repository
{

  // -- Constructors --

  /**
   * Constructs a Repository node
   * with the given associated DOM element.
   */
  public RepositoryNode(Element element) { super(element); }

  /**
   * Constructs a Repository node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public RepositoryNode(CustomAttributesNode parent) {
    this(parent, true);
  }

  /**
   * Constructs a Repository node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public RepositoryNode(CustomAttributesNode parent,
    boolean attach)
  {
    super(parent, "Repository", attach);
  }

  /**
   * Constructs a Repository node,
   * creating its associated DOM element beneath the
   * given parent, using the specified parameter values.
   */
  public RepositoryNode(CustomAttributesNode parent, Boolean isLocal,
    String path, String imageServerURL)
  {
    this(parent, true);
    setLocal(isLocal);
    setPath(path);
    setImageServerURL(imageServerURL);
  }


  // -- Repository API methods --

  /**
   * Gets IsLocal attribute
   * of the Repository element.
   */
  public Boolean isLocal() {
    return getBooleanAttribute("IsLocal");
  }

  /**
   * Sets IsLocal attribute
   * for the Repository element.
   */
  public void setLocal(Boolean value) {
    setAttribute("IsLocal", value);  }

  /**
   * Gets Path attribute
   * of the Repository element.
   */
  public String getPath() {
    return getAttribute("Path");
  }

  /**
   * Sets Path attribute
   * for the Repository element.
   */
  public void setPath(String value) {
    setAttribute("Path", value);  }

  /**
   * Gets ImageServerURL attribute
   * of the Repository element.
   */
  public String getImageServerURL() {
    return getAttribute("ImageServerURL");
  }

  /**
   * Sets ImageServerURL attribute
   * for the Repository element.
   */
  public void setImageServerURL(String value) {
    setAttribute("ImageServerURL", value);  }

  /**
   * Gets a list of Thumbnail elements
   * referencing this Repository node.
   */
  public List getThumbnailList() {
    return getAttrReferringNodes("Thumbnail", "Repository");
  }

  /**
   * Gets the number of Thumbnail elements
   * referencing this Repository node.
   */
  public int countThumbnailList() {
    return getAttrReferringCount("Thumbnail", "Repository");
  }

  /**
   * Gets a list of Pixels elements
   * referencing this Repository node.
   */
  public List getPixelsList() {
    return getAttrReferringNodes("Pixels", "Repository");
  }

  /**
   * Gets the number of Pixels elements
   * referencing this Repository node.
   */
  public int countPixelsList() {
    return getAttrReferringCount("Pixels", "Repository");
  }

  /**
   * Gets a list of OTF elements
   * referencing this Repository node.
   */
  public List getOTFList() {
    return getAttrReferringNodes("OTF", "Repository");
  }

  /**
   * Gets the number of OTF elements
   * referencing this Repository node.
   */
  public int countOTFList() {
    return getAttrReferringCount("OTF", "Repository");
  }

  /**
   * Gets a list of OriginalFile elements
   * referencing this Repository node.
   */
  public List getOriginalFileList() {
    return getAttrReferringNodes("OriginalFile", "Repository");
  }

  /**
   * Gets the number of OriginalFile elements
   * referencing this Repository node.
   */
  public int countOriginalFileList() {
    return getAttrReferringCount("OriginalFile", "Repository");
  }

}
