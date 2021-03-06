/*
 * org.openmicroscopy.xml.ThresholdNode
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
 * ThresholdNode is the node corresponding to the
 * "Threshold" XML element.
 *
 * Name: Threshold
 * AppliesTo: F
 * Location: OME/src/xml/OME/Analysis/FindSpots/spotModules.ome
 */
public class ThresholdNode extends AttributeNode
  implements Threshold
{

  // -- Constructors --

  /**
   * Constructs a Threshold node
   * with the given associated DOM element.
   */
  public ThresholdNode(Element element) { super(element); }

  /**
   * Constructs a Threshold node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public ThresholdNode(CustomAttributesNode parent) {
    this(parent, true);
  }

  /**
   * Constructs a Threshold node,
   * creating its associated DOM element beneath the
   * given parent.
   */
  public ThresholdNode(CustomAttributesNode parent,
    boolean attach)
  {
    super(parent, "Threshold", attach);
  }

  /**
   * Constructs a Threshold node,
   * creating its associated DOM element beneath the
   * given parent, using the specified parameter values.
   */
  public ThresholdNode(CustomAttributesNode parent, Float threshold)
  {
    this(parent, true);
    setThreshold(threshold);
  }


  // -- Threshold API methods --

  /**
   * Gets Threshold attribute
   * of the Threshold element.
   */
  public Float getThreshold() {
    return getFloatAttribute("Threshold");
  }

  /**
   * Sets Threshold attribute
   * for the Threshold element.
   */
  public void setThreshold(Float value) {
    setAttribute("Threshold", value);  }

}
