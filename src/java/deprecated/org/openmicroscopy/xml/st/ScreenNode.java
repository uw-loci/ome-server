/*
 * org.openmicroscopy.xml.ScreenNode
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
 * ScreenNode is the node corresponding to the
 * "Screen" XML element.
 *
 * Name: Screen
 * AppliesTo: G
 * Location: OME/src/xml/OME/Core/Screen.ome
 * Description: Almacena informacion acerca de una pantalla de
 *   "high-throughput"
 */
public class ScreenNode extends AttributeNode
  implements Screen
{

  // -- Constructors --

  /**
   * Constructs a Screen node
   * with the given associated DOM element.
   */
  public ScreenNode(Element element) { super(element); }

  /**
   * Constructs a Screen node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public ScreenNode(CustomAttributesNode parent) {
    this(parent, true);
  }

  /**
   * Constructs a Screen node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public ScreenNode(CustomAttributesNode parent,
    boolean attach)
  {
    super(parent, "Screen", attach);
  }

  /**
   * Constructs a Screen node,
   * creating its associated DOM element beneath the
   * given parent, using the specified parameter values.
   */
  public ScreenNode(CustomAttributesNode parent, String name,
    String description, String externalReference)
  {
    this(parent, true);
    setName(name);
    setDescription(description);
    setExternalReference(externalReference);
  }


  // -- Screen API methods --

  /**
   * Gets Name attribute
   * of the Screen element.
   */
  public String getName() {
    return getAttribute("Name");
  }

  /**
   * Sets Name attribute
   * for the Screen element.
   */
  public void setName(String value) {
    setAttribute("Name", value);  }

  /**
   * Gets Description attribute
   * of the Screen element.
   */
  public String getDescription() {
    return getAttribute("Description");
  }

  /**
   * Sets Description attribute
   * for the Screen element.
   */
  public void setDescription(String value) {
    setAttribute("Description", value);  }

  /**
   * Gets ExternalReference attribute
   * of the Screen element.
   */
  public String getExternalReference() {
    return getAttribute("ExternalReference");
  }

  /**
   * Sets ExternalReference attribute
   * for the Screen element.
   */
  public void setExternalReference(String value) {
    setAttribute("ExternalReference", value);  }

  /**
   * Gets a list of Plate elements
   * referencing this Screen node.
   */
  public List getPlateList() {
    return getAttrReferringNodes("Plate", "Screen");
  }

  /**
   * Gets the number of Plate elements
   * referencing this Screen node.
   */
  public int countPlateList() {
    return getAttrReferringCount("Plate", "Screen");
  }

  /**
   * Gets a list of PlateScreen elements
   * referencing this Screen node.
   */
  public List getPlateScreenList() {
    return getAttrReferringNodes("PlateScreen", "Screen");
  }

  /**
   * Gets the number of PlateScreen elements
   * referencing this Screen node.
   */
  public int countPlateScreenList() {
    return getAttrReferringCount("PlateScreen", "Screen");
  }

}
