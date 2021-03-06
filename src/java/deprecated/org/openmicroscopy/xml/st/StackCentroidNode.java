/*
 * org.openmicroscopy.xml.StackCentroidNode
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

import ome.xml.OMEXMLNode;
import org.openmicroscopy.xml.*;
import org.openmicroscopy.ds.st.*;
import org.w3c.dom.Element;

/**
 * StackCentroidNode is the node corresponding to the
 * "StackCentroid" XML element.
 *
 * Name: StackCentroid
 * AppliesTo: I
 * Location: OME/src/xml/OME/Import/ImageServerStatistics.ome
 */
public class StackCentroidNode extends AttributeNode
  implements StackCentroid
{

  // -- Constructors --

  /**
   * Constructs a StackCentroid node
   * with the given associated DOM element.
   */
  public StackCentroidNode(Element element) { super(element); }

  /**
   * Constructs a StackCentroid node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public StackCentroidNode(CustomAttributesNode parent) {
    this(parent, true);
  }

  /**
   * Constructs a StackCentroid node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public StackCentroidNode(CustomAttributesNode parent,
    boolean attach)
  {
    super(parent, "StackCentroid", attach);
  }

  /**
   * Constructs a StackCentroid node,
   * creating its associated DOM element beneath the
   * given parent, using the specified parameter values.
   */
  public StackCentroidNode(CustomAttributesNode parent, Integer theC,
    Integer theT, Float x, Float y, Float z)
  {
    this(parent, true);
    setTheC(theC);
    setTheT(theT);
    setX(x);
    setY(y);
    setZ(z);
  }


  // -- StackCentroid API methods --

  /**
   * Gets TheC attribute
   * of the StackCentroid element.
   */
  public Integer getTheC() {
    return getIntegerAttribute("TheC");
  }

  /**
   * Sets TheC attribute
   * for the StackCentroid element.
   */
  public void setTheC(Integer value) {
    setAttribute("TheC", value);  }

  /**
   * Gets TheT attribute
   * of the StackCentroid element.
   */
  public Integer getTheT() {
    return getIntegerAttribute("TheT");
  }

  /**
   * Sets TheT attribute
   * for the StackCentroid element.
   */
  public void setTheT(Integer value) {
    setAttribute("TheT", value);  }

  /**
   * Gets X attribute
   * of the StackCentroid element.
   */
  public Float getX() {
    return getFloatAttribute("X");
  }

  /**
   * Sets X attribute
   * for the StackCentroid element.
   */
  public void setX(Float value) {
    setAttribute("X", value);  }

  /**
   * Gets Y attribute
   * of the StackCentroid element.
   */
  public Float getY() {
    return getFloatAttribute("Y");
  }

  /**
   * Sets Y attribute
   * for the StackCentroid element.
   */
  public void setY(Float value) {
    setAttribute("Y", value);  }

  /**
   * Gets Z attribute
   * of the StackCentroid element.
   */
  public Float getZ() {
    return getFloatAttribute("Z");
  }

  /**
   * Sets Z attribute
   * for the StackCentroid element.
   */
  public void setZ(Float value) {
    setAttribute("Z", value);  }

}
