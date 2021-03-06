/*
 * org.openmicroscopy.xml.StageLabelNode
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
 * StageLabelNode is the node corresponding to the
 * "StageLabel" XML element.
 *
 * Name: StageLabel
 * AppliesTo: I
 * Location: OME/src/xml/OME/Core/Image.ome
 * Description: Stage labels are stage coordinates and a label to recall a
 *   microscope stage location
 */
public class StageLabelNode extends AttributeNode
  implements StageLabel
{

  // -- Constructors --

  /**
   * Constructs a StageLabel node
   * with the given associated DOM element.
   */
  public StageLabelNode(Element element) { super(element); }

  /**
   * Constructs a StageLabel node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public StageLabelNode(CustomAttributesNode parent) {
    this(parent, true);
  }

  /**
   * Constructs a StageLabel node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public StageLabelNode(CustomAttributesNode parent,
    boolean attach)
  {
    super(parent, "StageLabel", attach);
  }

  /**
   * Constructs a StageLabel node,
   * creating its associated DOM element beneath the
   * given parent, using the specified parameter values.
   */
  public StageLabelNode(CustomAttributesNode parent, String name, Float x,
    Float y, Float z)
  {
    this(parent, true);
    setName(name);
    setX(x);
    setY(y);
    setZ(z);
  }


  // -- StageLabel API methods --

  /**
   * Gets Name attribute
   * of the StageLabel element.
   */
  public String getName() {
    return getAttribute("Name");
  }

  /**
   * Sets Name attribute
   * for the StageLabel element.
   */
  public void setName(String value) {
    setAttribute("Name", value);  }

  /**
   * Gets X attribute
   * of the StageLabel element.
   */
  public Float getX() {
    return getFloatAttribute("X");
  }

  /**
   * Sets X attribute
   * for the StageLabel element.
   */
  public void setX(Float value) {
    setAttribute("X", value);  }

  /**
   * Gets Y attribute
   * of the StageLabel element.
   */
  public Float getY() {
    return getFloatAttribute("Y");
  }

  /**
   * Sets Y attribute
   * for the StageLabel element.
   */
  public void setY(Float value) {
    setAttribute("Y", value);  }

  /**
   * Gets Z attribute
   * of the StageLabel element.
   */
  public Float getZ() {
    return getFloatAttribute("Z");
  }

  /**
   * Sets Z attribute
   * for the StageLabel element.
   */
  public void setZ(Float value) {
    setAttribute("Z", value);  }

}
